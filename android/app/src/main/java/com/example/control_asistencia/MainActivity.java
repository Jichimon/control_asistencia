package com.example.control_asistencia;

import android.os.Bundle;

import com.example.control_asistencia.services.DatabaseConnectionService;
import com.example.control_asistencia.services.channels.MethodChannelService;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
    private BinaryMessenger binaryMessenger;


    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binaryMessenger = getFlutterEngine().getDartExecutor().getBinaryMessenger();
        GeneratedPluginRegistrant.registerWith(getFlutterEngine());
        DatabaseConnectionService.getInstance(getContext());
        new MethodChannelService(binaryMessenger);
    }
}
