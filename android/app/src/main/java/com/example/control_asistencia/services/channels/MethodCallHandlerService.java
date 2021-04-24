package com.example.control_asistencia.services.channels;

import androidx.annotation.NonNull;

import java.nio.ByteBuffer;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;

public class MethodCallHandlerService implements MethodCallHandler {

    ChannelService service;

    MethodCallHandlerService() {
        service = new ChannelService();
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        switch (call.method) {
            case "setImagesToIdentify":
                Byte[] imageData = call.arguments();

                //TODO

                break;
            case "getIdentifyResponse":

                //TODO

                break;
            case "setNewUser":

                //TODO

                break;

            default:
                result.notImplemented();
        }
    }

}
