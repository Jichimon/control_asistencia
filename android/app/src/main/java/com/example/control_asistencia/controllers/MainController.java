package com.example.control_asistencia.controllers;

import com.example.control_asistencia.controllers.tasks.IdentifyTask;
import com.example.control_asistencia.controllers.tasks.SetNewUserTemplates;
import com.example.control_asistencia.models.Face;
import com.example.control_asistencia.models.UserImages;
import com.example.control_asistencia.services.DatabaseConnectionService;
import com.luxand.FSDK;

import java.util.ArrayList;
import java.util.concurrent.ExecutionException;

public class MainController {


    //CODES
    public static final int SUCCESSFULLY_COMPLETED = 0;
    public static final int CREATE_USER_ERROR = -1;
    public static final int LICENSE_ERROR = -2;
    public static final int DATABASE_CALL_ERROR = -3;
    public static final int NO_FACE_IN_DATABASE = -4;
    public static final int MATCHING_FACES_NO_RESULT = -1;
    public static final int NO_FACE_IN_THE_IMAGE = -10;
    public static final int NO_RESULT_FROM_ASYNC_TASK = -5;

    //Luxand_Licence_Free_Trial to 21/05/2021
    private static final String FREE_TRIAL_LICENSE = "fvTNKVHUnK5qwgJpGYh0ofv4ENmT0pVZc1ugdH6UdpD3TviITcWzt6t64/QlBHFfMYZWLqWHazh0uIiMsZ92tvPTWb0cRJANm9z37jg7nrhrC/7H4oFUUlz62WLZo7qWjA7rW4GSCSaoO7/74mziq1T0E0q8ENAOfuumQC9wpnY=";

    //properties
    private ArrayList<Face> allFaces;
    private final DatabaseConnectionService db = DatabaseConnectionService.getInstance(null);

    private static MainController mc;

    //constructor
    private MainController() {
    }

    public static MainController getInstance() {
        if(mc == null) {
            mc = new MainController();
        }
        return mc;
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

    public ArrayList<Face> getAllFaces() {
        return allFaces;
    }

    
    public int setNewUser(UserImages userImages){
        SetNewUserTemplates setNewUserTask = new SetNewUserTemplates();
        try {
            setNewUserTask.execute(userImages);
            return (int)setNewUserTask.get();
        } catch (InterruptedException | ExecutionException e) {
            e.printStackTrace();
            return -5;
        }
    }
    
    public int setImageToIdentify(byte[] imageData) {
        IdentifyTask identifyTask = new IdentifyTask();
        try {
            identifyTask.execute(imageData);
            return (int)identifyTask.get();
        } catch (InterruptedException | ExecutionException e) {
            e.printStackTrace();
            return -5;
        }
    }
    

    //__________________private Methods___________________________

    private void setAllFaces() {
        allFaces = db.getFaces();
    }
    
}
