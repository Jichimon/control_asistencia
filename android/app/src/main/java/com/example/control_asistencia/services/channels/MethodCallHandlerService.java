
package com.example.control_asistencia.services.channels;

import androidx.annotation.NonNull;

import com.example.control_asistencia.controllers.MainController;
import com.example.control_asistencia.models.UserImages;

import java.util.ArrayList;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;

public class MethodCallHandlerService implements MethodCallHandler {

    private final MainController controller;

    MethodCallHandlerService() {
        controller = MainController.getInstance();
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        int response;
        switch (call.method) {
            case "setImageToIdentify":
                byte[] imageData = call.arguments();
                response = controller.setImageToIdentify(imageData);
                //devuelve el id del usuario correctamente enrolado
                result.success(response);
                break;

            case "setNewUser":
                ArrayList<byte[]> images = call.argument("images");
                if ( call.argument("userId")!= null && images != null) {
                    int userId = call.argument("userId");
                    UserImages userImages = new UserImages(userId, images);
                    System.out.println( "+++++ METHODCALLHANDLERSERVICE +++++++  " + userId + "  " + "images: " + images.size() );
                    response = controller.setNewUser(userImages);
                    if (response == 0) {
                        result.success(response);
                        break;
                    }
                    result.error("code: " + response, "no se creo el usuario correctamente", "");
                    break;
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

