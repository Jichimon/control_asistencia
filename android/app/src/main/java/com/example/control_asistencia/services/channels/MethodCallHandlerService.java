
package com.example.control_asistencia.services.channels;

import androidx.annotation.NonNull;

import java.util.ArrayList;

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

                int userId = call.argument("userId");
                String userName = call.argument("userName");
                ArrayList<byte[]> images = call.argument("images");

                System.out.println( "+++++++  " + userId + "  " + userName + "  " + "images: " + images.size() );
                break;

            case "onInit":

                //TODO: cargar todos los templates de la base de datos en un array


                break;

            default:
                result.notImplemented();
        }
    }

}

