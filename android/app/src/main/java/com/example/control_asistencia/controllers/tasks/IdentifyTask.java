package com.example.control_asistencia.controllers.tasks;

import android.os.AsyncTask;

import com.example.control_asistencia.controllers.MainController;
import com.example.control_asistencia.models.Face;
import com.example.control_asistencia.services.DatabaseConnectionService;
import com.example.control_asistencia.services.ImageHandlerService;
import com.luxand.FSDK;

import java.util.ArrayList;


public class IdentifyTask extends AsyncTask<byte[], Integer, Integer> {

    //properties
    private final ArrayList<Face> allFaces = MainController.getInstance().getAllFaces();
    private final ImageHandlerService imageHandler = ImageHandlerService.getInstance();


    @Override
    protected Integer doInBackground(byte[]... imageData) {
        //HImage es la estructura de datos para imagenes con la que trabaja FaceSDK
        FSDK.HImage imageRaw = imageHandler.convertBytesBufferToHImage(imageData[0]);
        FSDK.HImage image = new FSDK.HImage();
        FSDK.CreateEmptyImage(image);
        FSDK.RotateImage90(imageRaw, 1, image);

        FSDK.TFacePosition facePosition = detectFaceInHImage(image);

        if (facePosition == null) {
            FSDK.FreeImage(image);
            return MainController.NO_FACE_IN_THE_IMAGE;
        }

        FSDK.FSDK_FaceTemplate faceTemplateFromImageStream = getFaceTemplate(image, facePosition);

        if (faceTemplateFromImageStream == null) {
            FSDK.FreeImage(image);
            return MainController.NO_FACE_IN_THE_IMAGE;
        }

        FSDK.FreeImage(image);

        //comparar el nuevo template con todos los que ya tenemos

        for (Face face : allFaces ) {
            FSDK.FSDK_FaceTemplate faceTemplateFromDB = new FSDK.FSDK_FaceTemplate();
            faceTemplateFromDB.template = face.getTemplate();
            int result = matchingFaceTemplates(faceTemplateFromImageStream, faceTemplateFromDB);
            if (result == FSDK.FSDKE_OK) {
                return face.getUserId();
            }
        }

        return MainController.MATCHING_FACES_NO_RESULT;
    }

    //metodos auxiliares
    private FSDK.TFacePosition detectFaceInHImage(FSDK.HImage image) {

        //Funcion que regula que la sensibilidad de la detección
        FSDK.SetFaceDetectionThreshold(5); //menor 1; mayor 5; 1-5;
        //20x20px es el tamaño minimo del face en la imagen para que el sdk lo detecte
        int internalResizeWidth = 512; //dimensionar la imagen a:
        FSDK.SetFaceDetectionParameters(false, false, internalResizeWidth);
        FSDK.TFacePosition facePosition = new FSDK.TFacePosition();
        int detectResponse = FSDK.DetectFace(image, facePosition);

        //handle response
        System.out.println("detect Face response_GetTFacePositionFromHImage: " + detectResponse);
        if (detectResponse == FSDK.FSDKE_OK) {
            return facePosition;
        }
        return null;
    }

    private FSDK.FSDK_FaceTemplate getFaceTemplate(FSDK.HImage image, FSDK.TFacePosition facePosition) {

        FSDK.FSDK_FaceTemplate faceTemplate = new FSDK.FSDK_FaceTemplate();
        //handle response
        if (facePosition != null) {
            //get template from the face already located
            int getTemplateResponse = FSDK.GetFaceTemplateInRegion(image, facePosition, faceTemplate);
            System.out.println("get Template Response_GetTemplateFromHImage: " + getTemplateResponse);
            if (getTemplateResponse == FSDK.FSDKE_OK) {
                return faceTemplate;
            }
        }
        return null;
    }


    private int matchingFaceTemplates(FSDK.FSDK_FaceTemplate template1, FSDK.FSDK_FaceTemplate template2) {
        float[] similarity = new float[1];
        float[] matchingRange = new float[1];
        FSDK.GetMatchingThresholdAtFAR(0.7f, matchingRange);
        int res = FSDK.MatchFaces(template1, template2, similarity);
        if (res == FSDK.FSDKE_OK) {
            if (similarity[0] > matchingRange[0]) {
                return 0;
            }
        }
        return MainController.MATCHING_FACES_NO_RESULT;
    }
}
