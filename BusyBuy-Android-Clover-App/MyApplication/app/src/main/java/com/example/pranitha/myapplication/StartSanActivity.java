package com.example.pranitha.myapplication;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.os.AsyncTask;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import com.clover.sdk.util.CloverAccount;
import com.clover.sdk.v3.order.Order;
import com.clover.sdk.v3.order.OrderConnector;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.BufferedInputStream;
import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Map;

import javax.net.ssl.HttpsURLConnection;

public class StartSanActivity extends Activity {
    private final BarcodeReceiver barcodeReceiver = new BarcodeReceiver();
    //private final OrderSavedReceiver orderSavedReceiver = new OrderSavedReceiver();
    private TextView mTextView;
    private Button scnButton;
    Context mContext;
    private static String customerInfo;
    private static String mid="4CBFA09JNERKA";
    SharedPreferences sharedpreferences;
    public static final String MyPREFERENCES = "orderData";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Intent intent = getIntent();
        mContext = this;
        final int optionId = intent.getIntExtra("scnOption", -1);

        registerReceiver(barcodeReceiver, new IntentFilter("com.clover.stripes.BarcodeBroadcast"));
        //registerReceiver(orderSavedReceiver, new IntentFilter("com.clover.intent.action.ORDER_SAVED"));
        setContentView(R.layout.activity_start_san);
        TextView title= (TextView) this.findViewById(R.id.layut_title);
        if(optionId==1)
        {
            title.setText("Scan Shoopping Cart");
        }
        else  if(optionId==2)
        {
            title.setText("Checkout");
        }
        else
        {
            title.setText("Scan customer ID");
        }
        mTextView = (TextView) this.findViewById(R.id.barcode_info);
        scnButton = (Button) this.findViewById(R.id.customer_info_continue_button);
        scnButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(final View v) {

                if (customerInfo != null) {
                    sharedpreferences = getSharedPreferences(MyPREFERENCES, Context.MODE_PRIVATE);
                    final String orderIdInfo = sharedpreferences.getString(customerInfo, null);
                    if (optionId == 1) {
                        Intent intent = new Intent("com.clover.intent.action.START_ORDER_MANAGE");
                        intent.putExtra("com.clover.intent.extra.ORDER_ID", orderIdInfo);
                        //intent.putExtra("com.clover.intent.extra.ORDER_ID", "QWV6H867053DW");
                        startActivity(intent);
                        ((Activity) v.getContext()).onBackPressed();
                    } else if (optionId == 2) {

                        AsyncTask<String, String, String> asyncTask = new AsyncTask<String, String, String>() {
                            @Override
                            protected String doInBackground(String... params) {
                                OrderConnector orderConnector = new OrderConnector(getBaseContext(), CloverAccount.getAccount(getBaseContext()), null);
                                orderConnector.connect();
                                try {
                                    Order order = orderConnector.getOrder(params[0]);
                                    orderConnector.disconnect();
                                    return order.getState();
                                } catch (Exception e) {
                                    e.printStackTrace();
                                    return e.getMessage();
                                }
                            }

                            @Override
                            protected void onPostExecute(String result) {
                                super.onPostExecute(result);
                                if ("LOCKED".equalsIgnoreCase(result)) {
                                    mTextView.setText("This Order is paid in full. Please deliver the bag to customer and go back to process next item");
                                    scnButton.setVisibility(View.INVISIBLE);
                                } else {
                                    Intent intent = new Intent("com.clover.intent.action.PAY");
                                    intent.putExtra("com.clover.intent.extra.ORDER_ID", orderIdInfo);
                                    startActivity(intent);
                                    ((Activity) mContext).onBackPressed();
                                }
                            }
                        };
                        //asyncTask.execute("AF6TKF3511DSG");
                        asyncTask.execute(orderIdInfo);
                    } else if (optionId == 0) {
                        /*Thread t = new Thread(){
                            public void run(){

                            }
                        };
                        t.start();
*/
                        AsyncTask<String, String, String> createasyncTask = new AsyncTask<String, String, String>() {
                            OrderConnector orderConnector;

                            @Override
                            protected void onPreExecute() {

                            }

                            @Override
                            protected String doInBackground(String... params) {

                                try {
                                    OrderConnector orderConnector = new OrderConnector(getBaseContext(), CloverAccount.getAccount(getBaseContext()), null);
                                    orderConnector.connect();
                                    Order order = new Order();
                                    order.setNote(customerInfo);
                                    //order.setState("UNLOCKED");
                                    order.setManualTransaction(true);
                                    Order order1 = orderConnector.createOrder(order);

                                            orderConnector.disconnect();
                                    return order1.getId();
                                } catch (Exception e) {
                                    e.printStackTrace();
                                    return e.getMessage();
                                }
                            }

                            @Override
                            protected void onPostExecute(String result) {
                                super.onPostExecute(result);
                                pushNotification(result, mid, "P2SYS", "created",customerInfo);
                                sharedpreferences = getSharedPreferences(MyPREFERENCES, Context.MODE_PRIVATE);
                                SharedPreferences.Editor editor = sharedpreferences.edit();
                                editor.putString(customerInfo, result);
                                editor.commit();
                                mTextView.setText("Customer Barcode is  scanned. Please go back and scan next item");
                                scnButton.setVisibility(View.INVISIBLE);
                                // ((Activity) mContext).onBackPressed();

                            }
                        };
                        createasyncTask.execute();

                    }
                } else {
                    mTextView.setText("Please scan the barcode and click on continue");
                }
            }
        });
    }

    @Override
    public void onPause() {
        super.onPause();
       // unregisterReceiver(orderSavedReceiver);
    }
    private class BarcodeReceiver extends BroadcastReceiver {
        @Override
        public void onReceive(Context context, Intent intent) {
            String action = intent.getAction();
            if (action.equals("com.clover.stripes.BarcodeBroadcast")) {
                String barcode = intent.getStringExtra("Barcode");
                if (barcode != null) {
                    //mTextView.setText("Barcode scanned : " + barcode);
                    mTextView.setText("Barcode scanned");
                    customerInfo = barcode;
                    unregisterReceiver(barcodeReceiver);
                }
            }
        }
    }
private class OrderSavedReceiver extends BroadcastReceiver {
        @Override
        public void onReceive(Context context, Intent intent) {
            String action = intent.getAction();
            if (action.equals("com.clover.intent.action.ORDER_SAVED")) {
                String orderId = intent.getStringExtra("com.clover.intent.extra.ORDER_ID");
                sharedpreferences = getSharedPreferences(MyPREFERENCES, Context.MODE_PRIVATE);
               Map<String,String> shp= (Map<String, String>) sharedpreferences.getAll();
                String json=null;
                for(String key: shp.keySet())
                {
                    if(shp.get(key).equalsIgnoreCase(orderId));
                    json=key;
                }
                if(json!=null) {
                        pushNotification(orderId, mid, "P2SYS", "paymentRequired", json);

                }
            }
        }
    }


    public static void pushNotification(String orderId, String merchantId, String merchantName,String state,String deviceId) {


        AsyncTask<String, String, String> asyncTask = new AsyncTask<String, String, String>() {
            @Override
            protected String doInBackground(String... params) {
                HttpsURLConnection urlConnection = null;
                URL url = null;
                try {
                    url = new URL("https://api.parse.com/1/push");
                    urlConnection = (HttpsURLConnection) url.openConnection();
                    urlConnection.setDoOutput(true);
                    urlConnection.setRequestMethod("POST");
                    urlConnection.addRequestProperty("X-Parse-Application-Id", "hbU9tCZAw9XO9NHgxLKElKjnlZFapRwp3vdLQaAS");
                    urlConnection.addRequestProperty("X-Parse-REST-API-Key", "jZW3AfgVIoE7sllvVGt2eRPZTqZZ60QDUNWsbAYK");
                    urlConnection.addRequestProperty("Content-Type", "application/json");
                    urlConnection.connect();
                    OutputStreamWriter out = new OutputStreamWriter(urlConnection.getOutputStream());
                    out.write(params[0]);
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
                return  "success";
            }


            @Override
            protected void onPostExecute(String result) {
                super.onPostExecute(result);
            }
        };
        //asyncTask.execute("AF6TKF3511DSG");
        try {
            JSONObject jsonParam1 = new JSONObject(deviceId);
            String devtoken = (String) jsonParam1.get("device_token");
            JSONObject jsonObject1 = new JSONObject();
            JSONObject jsonObject2 = new JSONObject();
            JSONObject jsonObject3 = new JSONObject();
            JSONArray ja= new JSONArray();
            ja.put(devtoken);
            jsonObject3.put("$in",ja);
            jsonObject2.put("deviceToken",jsonObject3);
            JSONObject jsonParam = new JSONObject();
            jsonParam.put("order_id", orderId);
            jsonParam.put("merchant_id", merchantId);
            jsonParam.put("merchant_name", merchantName);
            jsonParam.put("status", state);
            if("created".equalsIgnoreCase(state))
            jsonParam.put("alert", "Your order is in queue and will be  processed soon");
            else
            jsonParam.put("alert", "Your order is processed and ready to pick up");

            jsonObject1.put("data", jsonParam);
            jsonObject1.put("where", jsonObject2);
            //jsonObject1.put("data", jsonObject2);
            asyncTask.execute(jsonObject1.toString());

        } catch (Exception e) {
            e.printStackTrace();
        }

    }
}
