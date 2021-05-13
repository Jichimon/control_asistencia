package com.example.control_asistencia.models;

import java.util.ArrayList;

public class UserImages {

    private int userId;
    private ArrayList<byte[]> images;

    public UserImages(int userId, ArrayList<byte[]> images) {
        this.userId = userId;
        this.images = images;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public ArrayList<byte[]> getImages() {
        return images;
    }

    public void setImages(ArrayList<byte[]> images) {
        this.images = images;
    }
}
