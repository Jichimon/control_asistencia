package com.example.control_asistencia.services;

import com.luxand.FSDK;


public class ImageHandlerService {

    //instance
    private static ImageHandlerService handle;

    //Singleton Constructor
    private ImageHandlerService() {
    }
    public static ImageHandlerService getInstance() {
        if (handle == null) {
            handle = new ImageHandlerService();
        }
        return handle;
    }

    //_____________________MAIN METHODS______________________________
    

    public FSDK.HImage convertBytesBufferToHImage(byte[] imageData) {
        FSDK.HImage image = new FSDK.HImage();
        int res = FSDK.LoadImageFromJpegBuffer(image, imageData, imageData.length);
        if (res == FSDK.FSDKE_OK) {
            System.out.println("Himage creada correctamente");
        } else {
            System.out.println("No se creo correctamente porque: " + res);
        }
        return image;
    }
}
