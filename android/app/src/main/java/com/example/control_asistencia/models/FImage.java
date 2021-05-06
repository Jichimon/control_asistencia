package com.example.control_asistencia.models;

public class FImage {

    private byte[] template;

    public FImage(byte[] template) {
        this.template = template;
    }

    public byte[] getTemplate() {
        return template;
    }

    public void setTemplate(byte[] template) {
        this.template = template;
    }
    
}
