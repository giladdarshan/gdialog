#include <napi.h>
#include <string>
#include <iostream>
#include <dlfcn.h>

////
// #include <chrono>
// #include <thread>
///


using std::cerr;
using std::cout;
using std::endl;
using std::string;
// using namespace Napi;

#ifdef __APPLE__
#define IS_SUPPORTED_PLATFORM true
const string SHARED_LIBRARY_EXT = "dylib";
#endif

#ifdef __linux__
#define IS_SUPPORTED_PLATFORM true
const string SHARED_LIBRARY_EXT = "so";
#endif

#if !defined IS_SUPPORTED_PLATFORM
  cerr << "Unsupported Platform";
  exit(EXIT_FAILURE);
#endif

string SWIFT_SHARED_LIBRARY_PATH = "";
Napi::Function nodeCB;
Napi::Env nodeEnv = NULL;

// const auto SWIFT_TEST = "swift_test";

const auto SWIFT_SET_OPTIONS = "swift_set_options";
const auto SWIFT_RUN_DIALOG = "swift_run_dialog";

// typedef int (*TestFunc)();
typedef char* (*SetOptionsFunc)(const char*);
typedef char* (*RunDialogFunc)(void(*)(const char*));

void *DLSymOrDie(void *lib, const string& func_name) {
  const auto func = dlsym(lib, func_name.c_str());
  const auto dlsym_error = dlerror();
  if (dlsym_error) {
    cerr << "Could not load symbol create: " << dlsym_error << endl;
    dlclose(lib);
    exit(EXIT_FAILURE);
  }
  return func;
}

void *DLOpenOrDie(const string& path) {
  const auto lib = dlopen(path.c_str(), RTLD_LAZY);
  if (!lib) {
    cerr << "Could not load library: " << dlerror() << endl;
    exit(EXIT_FAILURE);
  }
  return lib;
}

// void Test(const Napi::CallbackInfo& info) {
//     Napi::Env env = info.Env();
//     int n = -1;
//     const auto swiftLib = DLOpenOrDie(SWIFT_SHARED_LIBRARY_PATH);
//     const auto _TEST = (TestFunc)DLSymOrDie(swiftLib, SWIFT_TEST);
//     Napi::Function cb;

//     n = _TEST();
//     cb = info[0].As<Napi::Function>();
//     Napi::Number result = Napi::Number::New(env, n);
//     cb.MakeCallback(env.Global(), { result });
// }

void dialogCallback(const char* returnString) {
  // cout << "CPP - BLAAA CALLBACK BLAAA " << returnString << endl;
  Napi::String result = Napi::String::New(nodeEnv, returnString);
  nodeCB.MakeCallback(nodeEnv.Global(), { result });
}

void SetOptions(const Napi::CallbackInfo& info) {
    Napi::Env env = info.Env();
    std::string n = "-1";
    std::string str = info[0].ToString();
    const auto swiftLib = DLOpenOrDie(SWIFT_SHARED_LIBRARY_PATH);
    const auto _SetOptionsFunc = (SetOptionsFunc)DLSymOrDie(swiftLib, SWIFT_SET_OPTIONS);
    Napi::Function cb;

    const char *options = str.c_str();
    n = _SetOptionsFunc(options);
    cb = info[1].As<Napi::Function>();
    // cout << "bla" << endl;
    // cout << n << endl;
    Napi::String result = Napi::String::New(env, n.c_str());
    cb.MakeCallback(env.Global(), { result });
}

void RunDialog(const Napi::CallbackInfo& info) {
  // cout << "RUNNING - " << sizeof(info)/sizeof(info[0]) << endl;
    // Napi::Env env = info.Env();
    nodeEnv = info.Env();
    std::string n = "-1";
    const auto swiftLib = DLOpenOrDie(SWIFT_SHARED_LIBRARY_PATH);
    const auto _RUN_DIALOG = (RunDialogFunc)DLSymOrDie(swiftLib, SWIFT_RUN_DIALOG);
    Napi::Function cb;
    nodeCB = info[1].As<Napi::Function>();
    void (*callbackPtr)(const char*) { &dialogCallback };
    n = _RUN_DIALOG(callbackPtr);
    cb = info[0].As<Napi::Function>();
    // n = _RUN_DIALOG();
    // cb = info[0].As<Napi::Function>();
    Napi::String result = Napi::String::New(nodeEnv, n.c_str());
    cb.MakeCallback(nodeEnv.Global(), { result });
}


void SetLibPath(const Napi::CallbackInfo& info) {
    // Napi::Env env = info.Env();
    SWIFT_SHARED_LIBRARY_PATH = info[0].ToString();
    // cout << "Setting Path:" << endl;
    // cout << SWIFT_SHARED_LIBRARY_PATH << endl;
}




///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Napi::Promise RunDialogPromise(const Napi::CallbackInfo& info) {
//     Napi::Env env = info.Env();
    
//     // std::string n = "-1";
//     // const auto swiftLib = DLOpenOrDie(SWIFT_SHARED_LIBRARY_PATH);
//     // const auto _RUN_DIALOG = (RunDialogFunc)DLSymOrDie(swiftLib, SWIFT_RUN_DIALOG);
//     // Napi::Function cb;

//     // n = _RUN_DIALOG();
//     // cb = info[0].As<Napi::Function>();
//     // Napi::String result = Napi::String::New(env, n.c_str());
//     // cb.MakeCallback(env.Global(), { result });


//     auto deferred = Napi::Promise::Deferred::New(env);
//     if (info.Length() != 2) {
//       deferred.Reject(Napi::TypeError::New(env, "Invalid argument count").Value());
//     }
//     else if (!info[0].IsNumber() || !info[1].IsNumber()) {
//       deferred.Reject(Napi::TypeError::New(env, "Invalid argument types").Value());
//     }
//     else {
//       // double arg0 = info[0].As<Napi::Number>().DoubleValue();
//       // double arg1 = info[1].As<Napi::Number>().DoubleValue();
//       // Napi::Number num = Napi::Number::New(env, arg0 + arg1);

//       std::string n = "-1";
//       const auto swiftLib = DLOpenOrDie(SWIFT_SHARED_LIBRARY_PATH);
//       const auto _RUN_DIALOG = (RunDialogFunc)DLSymOrDie(swiftLib, SWIFT_RUN_DIALOG);
//       // Napi::Function cb;

//       n = _RUN_DIALOG();
//       // cb = info[0].As<Napi::Function>();
//       Napi::String result = Napi::String::New(env, n.c_str());
//       // cb.MakeCallback(env.Global(), { result });

//       deferred.Resolve({ result });
//     }

//     return deferred.Promise();

// }

// class DialogAsyncWorker : public Napi::AsyncWorker {
    
//     public:
//         DialogAsyncWorker(Napi::Function& callback): AsyncWorker(callback), result("-1") {};
//         virtual ~DialogAsyncWorker() {};

//         void Execute() {
//           // Napi::Env env = info.Env();
//           // std::string n = "-1";
//           cout << "Test 1" << endl;
//           const auto swiftLib = DLOpenOrDie(SWIFT_SHARED_LIBRARY_PATH);
//           const auto _RUN_DIALOG = (RunDialogFunc)DLSymOrDie(swiftLib, SWIFT_RUN_DIALOG);
//           // Napi::Function cb;
//           cout << "Test 2" << endl;
          
//           result = _RUN_DIALOG();
//           cout << "Test 3" << endl;
//           // n = _RUN_DIALOG();
//           // cb = info[0].As<Napi::Function>();
//           // Napi::String result = Napi::String::New(env, n.c_str());
//           // cb.MakeCallback(env.Global(), { result });
          
//           // std::this_thread::sleep_for(std::chrono::seconds(runTime));
//           // if (runTime == 4) {
//           //   SetError ("Oops! Failed after 'working' 4 seconds.");
//           // }
//         }
//         void OnOK() {
//           // std::string msg = "SimpleAsyncWorker returning after 'working' " + std::to_string(runTime) + " seconds.";
//           Callback().Call({Env().Null(), Napi::String::New(Env(), result)});
//         }

//     private:
//         std::string result = "-1";
// };

// Napi::Value runDialogAsyncWorker(const Napi::CallbackInfo& info) {
//     // int runTime = info[0].As<Napi::Number>();
//     Napi::Function callback = info[0].As<Napi::Function>();
//     DialogAsyncWorker* asyncWorker = new DialogAsyncWorker(callback);
//     asyncWorker->Queue();
//     // std::string msg = "SimpleAsyncWorker for " + std::to_string(runTime) + " seconds queued.";
//     std::string msg = "Dialog loaded";
//     return Napi::String::New(info.Env(),msg.c_str());
// };



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// callback method when module is registered with Node.js
Napi::Object Init(Napi::Env env, Napi::Object exports){
    // set a key on `exports` object
    // exports.Set(
    //     Napi::String::New(env, "test"),
    //     Napi::Function::New(env, Test)
    // );
    exports.Set(
        Napi::String::New(env, "setOptions"),
        Napi::Function::New(env, SetOptions)
    );
    exports.Set(
        Napi::String::New(env, "setLibPath"),
        Napi::Function::New(env, SetLibPath)
    );
    exports.Set(
        Napi::String::New(env, "run"),
        Napi::Function::New(env, RunDialog)
    );
    // exports.Set(
    //     Napi::String::New(env, "runPromise"),
    //     Napi::Function::New(env, RunDialogPromise)
    // );
    // exports.Set(
    //     Napi::String::New(env, "runSimpleAsyncWorker"),
    //     Napi::Function::New(env, runSimpleAsyncWorker)
    // );
    // exports["runSimpleAsyncWorker"] = Napi::Function::New(env, runSimpleAsyncWorker, std::string("runSimpleAsyncWorker"));
    // exports["runDialogAsyncWorker"] = Napi::Function::New(env, runDialogAsyncWorker, std::string("runDialogAsyncWorker"));
    
    
    return exports;
}

NODE_API_MODULE(gDialog, Init)