class Worker {
    constructor() {
        this.path = require('path');
        this.is_app_bundle;
        this.gDialog;
        this.root_folder;
        this.application_name;
        this.callback;
    }
    configure(settings) {
        this.is_app_bundle = settings.is_app_bundle;
        this.root_folder = settings.root_folder;
        this.application_name = settings.application_name;
        this.callback = settings.callbackFunc;
        this.gDialog = this.is_app_bundle ? require(this.path.join(this.root_folder, '..', "Resources", `${this.application_name}`)) : require('bindings')(this.application_name);
        this.gDialog.setLibPath(settings.swiftLibPath);
    }
    show_gDialog(options) {
        let gDialog_result;
        
        this.gDialog.setOptions(JSON.stringify(options), result => {
            gDialog_result = result;
        });
        this.gDialog.run(result => {
            gDialog_result = result;
        }, this.workerCallback);
        
        if (!options.hasOwnProperty("no_return") || (options["no_return"] === false)) {
            if (gDialog_result !== "") {
                return gDialog_result;
            }
        }
        return '';
    }
    workerCallback(returnString) {
        process.send({ message: returnString });
    }
}

// if (require.main === module) {
//     console.log('called directly 2');
// } else {
//     console.log('required as a module 2');
// }
const worker = new Worker();

process.on("message", data => {
    worker.configure(data.settings);
    process.send({ result: worker.show_gDialog(data.options) });
    process.exit(0);
});
