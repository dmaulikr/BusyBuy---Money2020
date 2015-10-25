package com.example.pranitha.myapplication;

import android.app.IntentService;
import android.content.Intent;
import android.content.Context;
import android.content.SharedPreferences;

import com.clover.sdk.util.CloverAccount;
import com.clover.sdk.v3.order.Order;
import com.clover.sdk.v3.order.OrderConnector;

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

/**
 * An {@link IntentService} subclass for handling asynchronous task requests in
 * a service on a separate handler thread.
 * <p/>
 * TODO: Customize class - update intent actions, extra parameters and static
 * helper methods.
 */

public class MyIntentService extends IntentService {
    public static final String PARAM_IN_MSG = "imsg";
    public static final String PARAM_OUT_MSG = "omsg";

    public MyIntentService() {
        super("MyIntentService");
    }

    @Override
    protected void onHandleIntent(Intent intent) {

        String orderId = intent.getStringExtra("OrderId");
        // String orderId = intent.getStringExtra("com.clover.intent.extra.ORDER_ID");
        SharedPreferences sharedpreferences = getApplicationContext().getSharedPreferences("orderData", Context.MODE_PRIVATE);
        Map<String, String> shp = (Map<String, String>) sharedpreferences.getAll();
        String json = null;
        for (String key : shp.keySet()) {
            if (shp.get(key).equalsIgnoreCase(orderId))
                json = key;
            //return;
        }
        if (json != null) {
            if (true) {
                try {
                    JSONObject jsonParam1 = new JSONObject(json);
                    String devtoken = (String) jsonParam1.get("device_token");
                    //String devtoken = "4c7876abdf40757040682868ef88f640fc8727153031049c14013aafbdcfef2d";
                    JSONObject jsonObject1 = new JSONObject();
                    JSONObject jsonObject2 = new JSONObject();
                    JSONObject jsonObject3 = new JSONObject();
                    JSONArray ja = new JSONArray();
                    ja.put(devtoken);
                    jsonObject3.put("$in", ja);
                    jsonObject2.put("deviceToken", jsonObject3);
                    JSONObject jsonParam = new JSONObject();
                    jsonParam.put("order_id", orderId);
                    OrderConnector orderConnector = new OrderConnector(getBaseContext(), CloverAccount.getAccount(getBaseContext()), null);
                    orderConnector.connect();
                    Order order = orderConnector.getOrder(orderId);
                    orderConnector.disconnect();

                    jsonParam.put("amount", (double) (order.getTotal() / 100));
                    jsonParam.put("merchant_id", "4CBFA09JNERKA");
                    jsonParam.put("merchant_name", "P2SYS");
                    jsonParam.put("status", "paymentRequested");
                    jsonParam.put("alert", "Your order is processed and ready to pick up");

                    jsonObject1.put("data", jsonParam);
                    jsonObject1.put("where", jsonObject2);


                    HttpsURLConnection urlConnection = null;
                    URL url = null;

                    url = new URL("https://api.parse.com/1/push");
                    urlConnection = (HttpsURLConnection) url.openConnection();
                    urlConnection.setDoOutput(true);
                    urlConnection.setRequestMethod("POST");
                    urlConnection.addRequestProperty("X-Parse-Application-Id", "hbU9tCZAw9XO9NHgxLKElKjnlZFapRwp3vdLQaAS");
                    urlConnection.addRequestProperty("X-Parse-REST-API-Key", "jZW3AfgVIoE7sllvVGt2eRPZTqZZ60QDUNWsbAYK");
                    urlConnection.addRequestProperty("Content-Type", "application/json");
                    urlConnection.connect();
                    OutputStreamWriter out = new OutputStreamWriter(urlConnection.getOutputStream());
                    out.write(jsonObject1.toString());
                    out.close();

                    InputStream in = new BufferedInputStream(urlConnection.getInputStream());
                    BufferedReader r = new BufferedReader(new InputStreamReader(in));
                    StringBuilder total = new StringBuilder();
                    String line;
                    while ((line = r.readLine()) != null) {
                        total.append(line);
                    }
                    total.toString();
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }

        }
    }
}