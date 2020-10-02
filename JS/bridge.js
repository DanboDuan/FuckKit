
class JSBridge {
    constructor () {
        this.bridgeScheme = 'fuckkit://';
        this.dispatchMsgPath = 'dispatch_message/';
        this.callbackId = 1000;
        this.callbackMap = {};
        this.eventHookMap = {};
        this.sendMessageQueue = [];
    }

    /**
     * app->web: 取出队列中的消息，并清空接收队列
     * @returns {string} bridge requests JSON.
     */
    _fetchQueue () {
        const messageQueueString = JSON.stringify(this.sendMessageQueue);
        this.sendMessageQueue = [];
        return messageQueueString;
    }

    /**
     * Dispatch message to native.
     * @private
     * @param {string} url
     */
    _dispatchUrlMsg (url) {
        if (typeof document !== 'undefined') {
            const iframe = document.createElement('iframe');
            iframe.style.display = 'none';
            document.body.appendChild(iframe);
            iframe.src = url;
            setTimeout(() => {
                document.body.removeChild(iframe);
            }, 300);
        }
    }

    /**
     * app->web: 执行JS函数,并将结果返回客户端
     * @param {string|BridgeResponse} message JSON data of BridgeResponse or base 64 string.
     */
    _handleMessageFromApp (message) {
        const params = message['__params'];
        let ret = {__err_code: 'cb404'};
        const callbackId = message['__callback_id'];

        if (typeof callbackId === 'string' && typeof this.callbackMap[callbackId] === 'function') {
            ret = this.callbackMap[callbackId](params);
            delete this.callbackMap[callbackId];
        } else if (typeof callbackId === 'string' && Array.isArray(this.eventHookMap[callbackId])) {
            this.eventHookMap[callbackId].forEach((handler) => {
                if (typeof handler === 'function') {
                    ret = handler(params);
                }
            });
        }

        return JSON.stringify(ret);
    }

    /**
     * @param {string} func Bridge function name.
     * @param {Object} params Bridge function params.
     * @param {callback} callback
     * @param {string} sdkVersion
     * @param {number} fromInnerOn
     */
    _call (func, params = {}, callback = null, sdkVersion = 3, fromInnerOn = 0, msgType = 'call') {
        if (!func || typeof func !== 'string') {
            return;
        }

        let callbackID;
        if (fromInnerOn) {
            callbackID = func;
        } else {
            this.callbackId += 1;
            callbackID = this.callbackId.toString();
        }

        if (typeof callback === 'function') {
            this.callbackMap[callbackID] = callback;
        }

        let msgJSON = {
            JSSDK: sdkVersion,
            func,
            params,
            __msg_type: msgType,
            __callback_id: callbackID,
        };

        try {
            if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.callMethodParams && "function" == typeof window.webkit.messageHandlers.callMethodParams.postMessage) {
                window.webkit.messageHandlers.callMethodParams.postMessage(msgJSON);
            } else if (window.androidJsBridge && "function" == typeof window.androidJsBridge.callMethodParams) {
                window.androidJsBridge.callMethodParams(JSON.stringify(msgJSON));
            } else {
                this.sendMessageQueue.push(msgJSON);
                this._dispatchUrlMsg(`${this.bridgeScheme}${this.dispatchMsgPath}`);
            }
        } catch (e) {
            console.error(e);
        }

    }

    /**
     * web: 自定义事件和回调
     * @param {string} event Event name.
     * @param {Function} callback
     */
    _on (event, callback, sdkVersion = 3) {
        if (!event || typeof event !== 'string' || typeof callback !== 'function') {
            return;
        }

        if (this.eventHookMap[event]) {
            this.eventHookMap[event].push(callback);
        } else {
            this.eventHookMap[event] = [callback];
        }

        const msgJSON = {
            JSSDK: sdkVersion,
            __msg_type: 'on',
            __callback_id: event,
            func: event,
        };

        try {
            if (window.androidJsBridge && "function" == typeof window.androidJsBridge.onMethodParams) {
                window.androidJsBridge.onMethodParams(JSON.stringify(msgJSON));
            } else if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.callMethodParams && "function" == typeof window.webkit.messageHandlers.callMethodParams.postMessage) { // for ios wkwebview
                window.webkit.messageHandlers.callMethodParams.postMessage(msgJSON);
            } else  { 
                this._call(event, {}, null, sdkVersion, 1, 'on');
            }
        } catch (e) {
            console.error(e);
        }
    }

    /**
     * web: 和on相对，解除注册
     * @param {string} event Event name.
     * @param {Function} callback
     */
    _off (event, callback, sdkVersion = 3) {
        if (!event || typeof event !== 'string' || typeof callback !== 'function') {
            return;
        }

        if (this.eventHookMap[event]) {
            this.eventHookMap[event] = this.eventHookMap[event].filter(_callback => _callback !== callback);
            if (this.eventHookMap[event].length > 0) {
                return;
            }

            const msgJSON = {
                JSSDK: sdkVersion,
                __msg_type: 'off',
                func: event,
            };

            try {
                if (window.androidJsBridge && "function" == typeof window.androidJsBridge.offMethodParams) {
                    window.androidJsBridge.offMethodParams(JSON.stringify(msgJSON));
                } else if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.callMethodParams && "function" == typeof window.webkit.messageHandlers.callMethodParams.postMessage) { // for ios wkwebview
                    window.webkit.messageHandlers.callMethodParams.postMessage(msgJSON);
                } else  { 
                    this._call(event, {}, null, sdkVersion, 0, 'off');
                }
            } catch (e) {
                console.error(e);
            }
        }
    }

    /**
     * Trigger event.
     * @param {string} event
     * @param {Object} msgParams
     * @returns {boolean} Has handled.
     */
    _trigger (event, msgParams) {
        const eventQueue = this.eventHookMap[event];
        let called = false;
        if (eventQueue) {
            for (let i = 0, len = eventQueue.length; i < len; i++) {
                const callback = eventQueue[i];
                if (typeof callback === 'function') {
                    called = true;
                    callback(msgParams);
                }
            }
        }

        return called;
    }

    init () {
        let jsbridge = {
            call: (...args) => this._call(...args),
            on: (...args) => this._on(...args),
            off: (...args) => this._off(...args),
            trigger: (...args) => this._trigger(...args),
        };
        if (typeof window !== 'undefined') {
            if (!window.Native2JSBridge || !window.JS2NativeBridge) { // 确认jsbridge是第一次被初始化
                // 对客户端暴露
                window.Native2JSBridge = {
                    _fetchQueue: (...args) => this._fetchQueue(...args),
                    _handleMessageFromApp: (...args) => this._handleMessageFromApp(...args),
                };
                // 对前端暴露
                window.JS2NativeBridge = jsbridge;
            } else {
                jsbridge = window.JS2NativeBridge;
            }
        }

        return jsbridge;
    }
}

const JSBInstance = new JSBridge();

export default JSBInstance.init();
