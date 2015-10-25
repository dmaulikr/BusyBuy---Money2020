package com.example.pranitha.myapplication;

import android.content.Intent;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;

public class ScanOptionsActivity extends AppCompatActivity implements View.OnClickListener{
    private Button scnCst;
    private Button scnBg;
    private Button scnChk;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_scan_options);
        scnCst= (Button) this.findViewById(R.id.scn_cst_btn);
        scnBg= (Button) this.findViewById(R.id.scn_bg_btn);
        scnChk= (Button) this.findViewById(R.id.scn_chk_btn);
        scnCst.setOnClickListener(this);
        scnBg.setOnClickListener(this);
        scnChk.setOnClickListener(this);
    }

    @Override
    public void onClick(View v) {
        int optionId=0;
        if(v.getId()==R.id.scn_bg_btn)
        {
            optionId=1;
        }
        else if(v.getId()==R.id.scn_chk_btn)
        {
            optionId=2;
        }
        Intent intent = new Intent(getApplicationContext(), StartSanActivity.class);
        intent.putExtra("scnOption",optionId);
        startActivity(intent);
    }
}
