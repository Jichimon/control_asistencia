package com.example.control_asistencia;

import android.os.Bundle;

import com.example.control_asistencia.services.channels.MethodChannelService;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {

    private MethodChannelService methodChannelService;
    private final BinaryMessenger binaryMessenger = getFlutterEngine().getDartExecutor().getBinaryMessenger();


    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this);
        methodChannelService = new MethodChannelService(binaryMessenger);


    }
}
