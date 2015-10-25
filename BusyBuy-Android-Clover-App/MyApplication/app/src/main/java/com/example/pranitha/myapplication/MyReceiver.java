package com.example.pranitha.myapplication;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;

import org.json.JSONArray;
import org.json.JSONObject;

import java.io.BufferedInputStream;
import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.net.URL;
import java.util.Map;

import javax.net.ssl.HttpsURLConnection;

public class MyReceiver extends BroadcastReceiver {
    public MyReceiver() {
    }

    @Override
    public void onReceive(Context context, Intent intent) {
        String action = intent.getAction();
        if (action.equals("com.clover.intent.action.ORDER_SAVED")) {
            String orderId = intent.getStringExtra("com.clover.intent.extra.ORDER_ID");
            Intent intent1= new Intent(context,MyIntentService.class);
            intent1.putExtra("OrderId", orderId);
            //context.startService(new Intent(context, MyIntentService.class));
            context.startService(intent1);
        }
    }
}
