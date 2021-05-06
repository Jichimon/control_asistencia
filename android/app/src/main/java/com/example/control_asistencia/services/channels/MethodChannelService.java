package com.example.control_asistencia.services.channels;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;

public class MethodChannelService extends MethodChannel {

    private static final String CHANNEL = "control_asistencia/flutter/canalDeDatos";
    private final MethodCallHandlerService callHandler = new MethodCallHandlerService();


    public MethodChannelService(BinaryMessenger messenger) {
        super(messenger, CHANNEL);
        setMethodCallHandler(callHandler);
    }
}