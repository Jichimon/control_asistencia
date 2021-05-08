package com.example.control_asistencia.controllers;

import com.example.control_asistencia.models.Face;
import com.example.control_asistencia.services.DatabaseConnectionService;
import com.example.control_asistencia.services.ImageHandlerService;
import com.luxand.FSDK;

import java.util.ArrayList;

public class MainController {


    //CODES
    public static final int SUCCESSFULLY_COMPLETED = 0;
    public static final int CREATE_USER_ERROR = -1;
    public static final int LICENSE_ERROR = -2;
    public static final int DATABASE_CALL_ERROR = -3;
    public static final int NO_FACE_IN_DATABASE = -4;
    public static final int MATCHING_FACES_NO_RESULT = -1;
    public static final int NO_FACE_IN_THE_IMAGE = -10;

    //Luxand_Licence_Free_Trial to 21/05/2021
    private static final String FREE_TRIAL_LICENSE = "fvTNKVHUnK5qwgJpGYh0ofv4ENmT0pVZc1ugdH6UdpD3TviITcWzt6t64/QlBHFfMYZWLqWHazh0uIiMsZ92tvPTWb0cRJANm9z37jg7nrhrC/7H4oFUUlz62WLZo7qWjA7rW4GSCSaoO7/74mziq1T0E0q8ENAOfuumQC9wpnY=";

    //properties
    private ArrayList<Face> allFaces;
    private final ImageHandlerService imageHandler = ImageHandlerService.getInstance();
    private final DatabaseConnectionService db = DatabaseConnectionService.getInstance(null);


    //constructor
    public MainController() {

    }


    //____________________Main_public_methods______________________
    public int onInit(){

        int res = FSDK.ActivateLibrary(FREE_TRIAL_LICENSE);
        if (res != FSDK.FSDKE_OK) {
            System.out.println("FaceSDK activation failed");
            return LICENSE_ERROR;
        } else {
            FSDK.Initialize();
            setAllFaces();
            if (allFaces == null) {
                return DATABASE_CALL_ERROR;
            } else if (allFaces.isEmpty()) {
                return NO_FACE_IN_DATABASE;
            }
            return SUCCESSFULLY_COMPLETED;
        }
    }
    
    public int  setNewUser(int userId, ArrayList<byte[]> images){
        db.openWritable();
        for (byte[] eachImageData : images) {

            //HImage es la estructura de datos para imagenes con la que trabaja FaceSDK
            FSDK.HImage image = imageHandler.convertBytesBufferToHImage(eachImageData);
            FSDK.MirrorImage(image, true);

            FSDK.TFacePosition facePosition = detectFaceInHImage(image);
            if (facePosition == null) {
                FSDK.FreeImage(image);
                return NO_FACE_IN_THE_IMAGE;
            }

            FSDK.FSDK_FaceTemplate faceTemplate = getFaceTemplate(image, facePosition);
            if (faceTemplate == null) {
                FSDK.FreeImage(image);
                return CREATE_USER_ERROR;
            }

            // ya tenemos el template, creamos el Face y lo metemos a la Database
            Face newFace = new Face(userId, faceTemplate.template);
            int res = ((int) db.insertFaceToDB(newFace));
            if (res == CREATE_USER_ERROR) {
                FSDK.FreeImage(image);
                return CREATE_USER_ERROR;
            }
            FSDK.FreeImage(image);
        }
        return SUCCESSFULLY_COMPLETED;
    }
    
    public int setImageToIdentify(byte[] imageData) {

        //HImage es la estructura de datos para imagenes con la que trabaja FaceSDK
        FSDK.HImage image = imageHandler.convertBytesBufferToHImage(imageData);

        FSDK.TFacePosition facePosition = detectFaceInHImage(image);

        if (facePosition == null) {
            FSDK.FreeImage(image);
            return NO_FACE_IN_THE_IMAGE;
        }

        FSDK.FSDK_FaceTemplate faceTemplateFromImageStream = getFaceTemplate(image, facePosition);

        if (faceTemplateFromImageStream == null) {
            FSDK.FreeImage(image);
            return NO_FACE_IN_THE_IMAGE;
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

        return MATCHING_FACES_NO_RESULT;
    }
    
    
    
    //__________________private Methods___________________________

    private void setAllFaces() {
        allFaces = db.getFaces();
    }

    private FSDK.TFacePosition detectFaceInHImage(FSDK.HImage image) {

        //Funcion que regula que la sensibilidad de la detección
        FSDK.SetFaceDetectionThreshold(3); //menor 1; mayor 5; 1-5;
        //20x20px es el tamaño minimo del face en la imagen para que el sdk lo detecte
        int internalResizeWidth = 512; //dimensionar la imagen a:
        FSDK.SetFaceDetectionParameters(true, false, internalResizeWidth);
        FSDK.TFacePosition facePosition = new FSDK.TFacePosition();
        int detectResponse = FSDK.DetectFace(image, facePosition);

        //handle response
        System.out.println("detect Face response_GetTemplateFromHImage: " + detectResponse);
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
        FSDK.GetMatchingThresholdAtFAR(0.80f, matchingRange);
        int res = FSDK.MatchFaces(template1, template2, similarity);
        if (res == FSDK.FSDKE_OK) {
            if (similarity[0] > matchingRange[0]) {
                return 0;
            }
        }
        return MATCHING_FACES_NO_RESULT;
    }

    
}
