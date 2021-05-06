
package com.example.control_asistencia.services.channels;

import androidx.annotation.NonNull;

import com.example.control_asistencia.controllers.MainController;

import java.util.ArrayList;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;

public class MethodCallHandlerService implements MethodCallHandler {

    private final MainController controller;

    MethodCallHandlerService() {
        controller = new MainController();
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        int response;
        switch (call.method) {
            case "setImagesToIdentify":
                byte[] imageData = call.arguments();
                response = controller.setImagesToIdentify(imageData);
                //devuelve el id del usuario correctamente enrolado
                result.success(response);
                break;

            case "setNewUser":
                ArrayList<byte[]> images = call.argument("images");
                if ( call.argument("userId")!= null && images != null) {
                    int userId = call.argument("userId");
                    System.out.println( "+++++ METHODCALLHANDLERSERVICE +++++++  " + userId + "  " + "images: " + images.size() );
                    response = controller.setNewUser(userId, images);
                    if (response == 0) {
                        result.success(response);
                    }
                    result.error("code: " + response, "no se creo el usuario correctamente", "");
                }
                result.error("No data sended", "empty arguments", "");
                break;

            case "onInit":
                response = controller.onInit();
                if (response == MainController.DATABASE_CALL_ERROR) {
                    result.error("DATABASE_CALL_ERROR", "No se cargaron las templates","");
                } else if (response == MainController.LICENSE_ERROR) {
                    result.error("NO_LICENCE", "No license activated","");
                }
                result.success(response);
                break;

            default:
                result.notImplemented();
        }
    }

}

