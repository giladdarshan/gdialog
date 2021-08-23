class gDialog {
    constructor() {
        this.application_name = "gDialog";
        this.application_version = "1.0.1";
        this.fs = require('fs');
        this.path = require('path');
        this.os = require('os');
        this.is_app_bundle = false;
        this.root_folder = (process.hasOwnProperty('pkg') ? this.path.dirname(process.execPath) : __dirname) + '';
        if (this.root_folder.endsWith(".app/Contents/MacOS")) {
            this.is_app_bundle = true;
        }
        this.directRun = require.main === module;
        this.templates_folder = this.is_app_bundle ? this.path.join(this.root_folder, '..', "Resources", "templates") : this.path.join(this.root_folder, "templates");
        
        this.templates_config_file = this.path.join(this.templates_folder, 'config.json');
        
        this.templates_config = {};
        
        this.options = {
            "option_types": {
                "icon_type": "string",
                "async": "bool-true"
            }
        };
        this.settings = {
            dylib_name: '.dylib'
        };
        
        this.callbackFunc = undefined;
        this.suppressAbortErr = false;
        this.argv_counter = 0;
        this.argv = process.argv.length > 2 ? process.argv.slice(2, process.argv.length) : [];
        this.#readTemplatesConfiguration();
    }
    printVersion() {
        console.log(this.application_version);
    }
    #findSwiftLib(libName, path) {
        try {
            path = path || this.root_folder;
            // console.log("Path:", path);
            let dirItems = fs.readdirSync(path);
            let folders = [];
            for (let i = 0; i < dirItems.length; i++) {
                let item = dirItems[i];
                let itemPath = `${path}/${item}`;
                if (fs.lstatSync(itemPath).isDirectory()) {
                    folders.push(itemPath);
                }
                else {
                    if (item === libName) {
                        return itemPath;
                    }    
                }
            }
            for (let j = 0; j < folders.length; j++) {
                let dirCheck = this.#findSwiftLib(libName, folders[j]);
                if (dirCheck !== false) {
                    return dirCheck;
                }
            }
        }
        catch(e) {
            console.error(e);
        }
        return false;
    }
    #readTemplatesConfiguration() {
        try {
            if (!this.fs.existsSync(this.templates_config_file)) {
                console.error(`Unable to find templates configuration file at "${this.templates_config_file}"`);
                return false;
            }
            this.templates_config = JSON.parse(this.fs.readFileSync(this.templates_config_file, 'utf8'));
            // Adding additional hidden flags to the global options
            this.templates_config.global_options["icon_type"] = "none";
        }
        catch (err) {
            console.error(err);
            return false;
        }
        return true;
    }
    #getOptionsSource(type, arg) {
        if (this.templates_config.global_options.hasOwnProperty(arg)) {
            return this.templates_config.global_options;
        }
        else if (this.templates_config.templates[type].options.hasOwnProperty(arg)) {
            return this.templates_config.templates[type].options;
        }
        else if (this.options.option_types.hasOwnProperty(arg)) {
            return this.options.option_types;
        }
        return;
    }
    #process_argv(arg, options) {
        let options_source = this.#getOptionsSource(options.type, arg);
        
        if (options_source) {
            try {
                let type_found = true;
                let value;
                switch(options_source[arg]) {
                    case 'string':
                        options[arg] = this.argv[++this.argv_counter];
                        break;
                    case 'image':
                        options[arg] = this.argv[++this.argv_counter];
                        break;
                    case 'float':
                        options[arg] = parseFloat(this.argv[++this.argv_counter])
                        break;
                    case 'int':
                        options[arg] = parseInt(this.argv[++this.argv_counter])
                        break;
                    case 'array-inc':
                        value = this.argv[++this.argv_counter];
                        if (!options[arg]) {
                            options[arg] = [];
                        }
                        options[arg].push(value);
                        break;
                    case 'array':
                        value = this.argv[++this.argv_counter];
                        if (value.indexOf('[') == 0) {
                            options[arg] = JSON.parse(value);
                        }
                        else {
                            options[arg] = [value.toString()];
                        }
                        break;
                    case 'size':
                        value = this.argv[++this.argv_counter].toLowerCase().split('x');
                        options[arg] = {
                            width: parseFloat(value[0]),
                            height: parseFloat(value[1])
                        };
                        break;
                    case 'bool-true':
                        options[arg] = true;
                        break;
                    case 'bool-false':
                        options[arg] = false;
                        break;
                    case 'none':
                        options[arg] = arg;
                        break;
                    default:
                        type_found = false;
                        console.log(`Type not found for arg ${arg}`);
                        break;
                }
                if (type_found) {
                    options.option_types[arg] = options_source[arg];
                }
            }
            catch(e) {
                console.error(`Switch Exception - Unable to find the option "${arg}."`);    
                console.error(e);
            }
        }
        else {
            console.error(`Unable to find the option "${arg}".`);
        }
    }
    #sendJobToWorker(data) {
        return new Promise((resolve, reject) => {
            this.worker.on('message', (message) => {
                if (message.hasOwnProperty("result")) {
                    resolve(message.result)
                }
                else {
                    this.callbackFunc(message.message);
                }
            });
            this.worker.on('error', reject);
            this.worker.on('close', (code) => {
                if (code !== 0)
                    reject(new Error(`Worker stopped with exit code ${code}`));
            });
            this.worker.send(data);
        });
    }
    
    setCallback(callbackFunc) {
        this.callbackFunc = callbackFunc;
    }
    close() {
        this.suppressAbortErr = true;
        this.abortController.abort();
    }
    async run(providedOptions) {
        return new Promise((resolve, reject) => {
            try {
                const options = Object.assign({}, this.options);
                const settings = Object.assign({}, this.settings);
                this.#processOptions(options, settings, providedOptions);
                if (this.callbackFunc !== undefined) {
                    options.async = 'true';
                }
                this.fork = require('child_process').fork;
                this.abortController = new AbortController();
                
                const { signal } = this.abortController;
                this.worker = this.fork(this.path.join(this.root_folder, 'gDialog_worker.js'), { signal });
                
                this.#sendJobToWorker({
                    settings: {
                        is_app_bundle: this.is_app_bundle,
                        root_folder: this.root_folder,
                        application_name: this.application_name,
                        swiftLibPath: settings.swiftLibPath
                    },
                    options: options
                }).then(result => {
                    resolve(result);
                }).catch(err => {
                    if ((err.code == "ABORT_ERR") && this.suppressAbortErr) {
                        this.suppressAbortErr = false;
                        resolve();
                    }
                    else {
                        reject(err);
                    }
                });
                
            }
            catch(e) {
                reject(e);
            }
        });
    }
    runSync(providedOptions) {
        try {
            const options = Object.assign({}, this.options);
            const settings = Object.assign({}, this.settings);
            this.#processOptions(options, settings, providedOptions);
            const gDialog = this.is_app_bundle ? require(this.path.join(this.root_folder, '..', "Resources", `${this.application_name}`)) : require('bindings')(this.application_name);
            gDialog.setLibPath(settings.swiftLibPath);
            let gDialog_result;
            gDialog.setOptions(JSON.stringify(options), result => {
                gDialog_result = result;
            });
            gDialog.run(result => {
                gDialog_result = result;
            });
            if (!options.hasOwnProperty("no_return") || (options["no_return"] === false)) {
                if (gDialog_result !== "") {
                    if (this.directRun) {
                        console.log(gDialog_result);
                    }
                    else {
                        return gDialog_result;
                    }
                }
            }
        }
        catch(e) {
            console.error(e);
            return false;
        }
    
        return true;
    }
    #processOptions(options, settings, providedOptions) {
        // Initialization  
        if (providedOptions) {
            let dialogType = providedOptions.type;
            for (let key in providedOptions) {
                options[key] = providedOptions[key];
                if (key !== "type") {
                    let option_type = this.#getOptionsSource(dialogType, key);
                    if (option_type) {
                        options.option_types[key] = option_type[key];
                    }
                }
            }
        }
        else if (this.argv.length > 0) {
            if (this.argv[0] == '--version' || this.argv[0] == '-v') {
                this.printVersion();
                process.exit(0);
            }
            if (this.templates_config.templates.hasOwnProperty(this.argv[0])) {
                options["type"] = this.argv[0];
            }
            else {
                console.error(`${this.application_name} does not have a template for type "${this.argv[0]}"`);
                process.exit(1);
            }
            for (this.argv_counter = 1; this.argv_counter < this.argv.length; this.argv_counter++) {
                let argv_value = this.argv[this.argv_counter] + '';
                this.#process_argv(argv_value.indexOf('--') == 0 ? argv_value.slice(2, argv_value.length) : argv_value.indexOf('-') == 0 ? argv_value.slice(1, argv_value.length) : argv_value, options);
            }
        }
        else {
            console.error(`${this.application_name} cannot be executed without parameters`);
            process.exit(1);
        }

        settings.dylib_name = this.templates_config.templates[options.type].file;
        settings.swiftLibPath =  this.fs.existsSync(this.path.join(this.templates_folder, settings.dylib_name)) ? this.path.join(this.templates_folder, settings.dylib_name) : this.#findSwiftLib(settings.dylib_name);
        if (settings.swiftLibPath === false) {
            console.error(`Unable to find template "${settings.dylib_name}"`);
            process.exit(2);
        }
        
        options["icon_type"] = "none";
        if (options.hasOwnProperty("icon_file")) {
            if (options.icon_file.indexOf('~/') == 0) {
                options.icon_file = this.path.join(this.os.homedir(), options.icon_file.slice(2, options.icon_file.length));

            }
            if (this.fs.existsSync(options.icon_file)) {
                options["icon_type"] = "file";
            }
            else {
                delete options.icon_file;
                if (options.hasOwnProperty("system_icon")) {
                    options["icon_type"] = "system";
                }
            }
        }
        else if (options.hasOwnProperty("system_icon")) {
            options["icon_type"] = "system";
        }
    }
}
module.exports = gDialog;

const gdialog = new gDialog();
if (require.main === module) {
    gdialog.runSync();
} 