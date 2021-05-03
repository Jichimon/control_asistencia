package com.example.control_asistencia.models;

public class Face {

    private byte[] template;
    private int userId;

    public Face(byte[] template) {
        this.template = template;
    }

    public Face(int userId, byte[] template) {
        this.template = template;
        this.userId = userId;
    }

    public byte[] getTemplate() {
        return template;
    }

    public void setTemplate(byte[] template) {
        this.template = template;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }
}
