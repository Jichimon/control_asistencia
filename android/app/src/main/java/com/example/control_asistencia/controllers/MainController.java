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
    public static final int MATCHING_FACES_NO_RESULT = -1;

    //Luxand_Licence_Free_Trial to 21/05/2021
    private static final String FREE_TRIAL_LICENSE = "fvTNKVHUnK5qwgJpGYh0ofv4ENmT0pVZc1ugdH6UdpD3TviITcWzt6t64/QlBHFfMYZWLqWHazh0uIiMsZ92tvPTWb0cRJANm9z37jg7nrhrC/7H4oFUUlz62WLZo7qWjA7rW4GSCSaoO7/74mziq1T0E0q8ENAOfuumQC9wpnY=";

    //properties
    private ArrayList<Face> allFaces;
    private final ImageHandlerService imageHandler = ImageHandlerService.getInstance();
    private final DatabaseConnectionService db = DatabaseConnectionService.getInstance();


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
            if (allFaces.isEmpty()) {
                return DATABASE_CALL_ERROR;
            }
            return SUCCESSFULLY_COMPLETED;
        }
    }
    
    public int  setNewUser(int userId, ArrayList<byte[]> images){
        db.openWritable();
        for (byte[] eachImageData : images) {

            FSDK.FSDK_FaceTemplate faceTemplate = getFaceTemplateFromRawData(eachImageData);
            if (faceTemplate == null) {
                return CREATE_USER_ERROR;
            }

            // ya tenemos el template, creamos el Face y lo metemos a la Database
            Face newFace = new Face(userId, faceTemplate.template);
            int res = ((int) db.insertFaceToDB(newFace));
            if (res == CREATE_USER_ERROR) {
                return CREATE_USER_ERROR;
            }
        }
        db.close();
        return SUCCESSFULLY_COMPLETED;
    }
    
    public int setImagesToIdentify(byte[] imageData) {

        FSDK.FSDK_FaceTemplate faceTemplateFromImageStream = getFaceTemplateFromRawData(imageData);

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


    private FSDK.FSDK_FaceTemplate getFaceTemplateFromRawData(byte[] imageData) {

        //HImage es la estructura de datos para imagenes con la que trabaja FaceSDK
        FSDK.HImage image;
        image = imageHandler.convertBytesBufferToHImage(imageData);

        FSDK.FSDK_FaceTemplate faceTemplate = new FSDK.FSDK_FaceTemplate();

        //Funcion que regula que la sensibilidad de la detección
        FSDK.SetFaceDetectionThreshold(4); //menor 1; mayor 5; 1-5;

        //20x20px es el tamaño minimo del face en la imagen para que el sdk lo detecte
        int internalResizeWidth = 512; //dimensionar la imagen a:
        FSDK.SetFaceDetectionParameters(true, false, internalResizeWidth);


        FSDK.TFacePosition facePosition = new FSDK.TFacePosition();
        int detectResponse = FSDK.DetectFace(image, facePosition);

        //handle response
        if (detectResponse == FSDK.FSDKE_OK) {

            System.out.println("detect Face response_GetTemplateFromHImage: " + detectResponse);

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