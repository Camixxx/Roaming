package com.example.g_demo;

import com.amap.api.location.AMapLocation;
import com.amap.api.location.AMapLocationClient;
import com.amap.api.location.AMapLocationClientOption;
import com.amap.api.location.AMapLocationListener;
import com.amap.api.location.AMapLocationClientOption.AMapLocationMode;
import com.amap.api.maps.AMap;
import com.amap.api.maps.CameraUpdateFactory;
import com.amap.api.maps.MapView;
import com.amap.api.maps.LocationSource.OnLocationChangedListener;
import com.amap.api.maps.model.LatLng;
import com.amap.api.navi.AMapNavi;
import com.amap.api.navi.AMapNaviListener;
import com.amap.api.navi.AMapNaviView;
import com.amap.api.navi.AMapNaviViewListener;
import com.amap.api.navi.enums.NaviType;
import com.amap.api.navi.model.AMapLaneInfo;
import com.amap.api.navi.model.AMapNaviCross;
import com.amap.api.navi.model.AMapNaviInfo;
import com.amap.api.navi.model.AMapNaviLocation;
import com.amap.api.navi.model.AMapNaviPath;
import com.amap.api.navi.model.AMapNaviStaticInfo;
import com.amap.api.navi.model.AMapNaviTrafficFacilityInfo;
import com.amap.api.navi.model.AimLessModeCongestionInfo;
import com.amap.api.navi.model.AimLessModeStat;
import com.amap.api.navi.model.NaviInfo;
import com.amap.api.navi.model.NaviLatLng;
import com.amap.api.navi.view.RouteOverLay;
import com.autonavi.tbt.NaviStaticInfo;
import com.autonavi.tbt.TrafficFacilityInfo;

import Util.TTSController;
import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.Toast;

public class Navi extends Base_Navi{
	private static final String TAG = "NaviActivity";

	//实例化语音
	protected TTSController mTtsManager;
	AMapNaviView mAMapNaviView;
	AMapNavi mAMapNavi;
	AMap amap;
	Button start_naiv;
	private double lat;
	private double lon;
	private double endlat;
	private double endlon;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.naiv);

		//获取AMapNavi实例
		mAMapNavi = AMapNavi.getInstance(getApplicationContext());
		mAMapNaviView = (AMapNaviView) findViewById(R.id.navi_view);
		mAMapNaviView.onCreate(savedInstanceState);
		initView();
		mAMapNavi.addAMapNaviListener(this);
		mAMapNavi.addAMapNaviListener(mTtsManager);

	}


	private void initView() {
		// TODO 自动生成的方法存根
		start_naiv=(Button)findViewById(R.id.start_naiv);
		amap=mAMapNaviView.getMap();
		Intent itent=getIntent();
		lat=itent.getDoubleExtra("startlat", 1);
		lon=itent.getDoubleExtra("startlon", 2);
		endlat=itent.getDoubleExtra("endlat", 3);
		endlon=itent.getDoubleExtra("endlon", 4);
		amap.moveCamera(CameraUpdateFactory.newLatLngZoom(new LatLng(lat, lon),19));
		start_naiv.setOnClickListener(this);
		mTtsManager = TTSController.getInstance(getApplicationContext());
		mTtsManager.init();

	}


	@Override
	protected void onResume() {
		super.onResume();
		mAMapNaviView.onResume();
	}

	@Override
	protected void onPause() {
		super.onPause();
		mAMapNaviView.onPause();

	}

	@Override
	protected void onDestroy() {
		super.onDestroy();
		mAMapNaviView.onDestroy();
		//since 1.6.0
		//不再在naviview destroy的时候自动执行AMapNavi.stopNavi();
		//请自行执行
		mAMapNavi.stopNavi();
		mAMapNavi.destroy();
	}


	@Override
	public void onCalculateRouteFailure(int arg0) {
		// TODO 自动生成的方法存根
		Toast.makeText(getApplicationContext(),"规划fail"
				,Toast.LENGTH_LONG).show();
		Log.i(TAG,"navi路径规划错误+"+arg0);
	}
	@Override
	public void onCalculateRouteSuccess() {
		// TODO 自动生成的方法存根
		Toast.makeText(getApplicationContext(),"成功规划"
				,Toast.LENGTH_LONG).show();
		AMapNaviPath naviPath = mAMapNavi.getNaviPath();
		if (naviPath == null){
			Toast.makeText(getApplicationContext(),"fail"
					,Toast.LENGTH_LONG).show();
			return;
		}
		Log.i(TAG,"navi路径规划成功");
		mTtsManager.startSpeaking("路径规划成功,开始导航");
		try {
			Thread.sleep(3000);
		} catch (InterruptedException e) {
			// TODO 自动生成的 catch 块
			e.printStackTrace();
		}
		mAMapNavi.startNavi(NaviType.GPS);
		mAMapNavi.startGPS();
	}

	@Override
	public void onInitNaviFailure() {
		// TODO 自动生成的方法存根
		Log.i(TAG,"失败");
	}
	@Override
	public void onInitNaviSuccess() {
		// TODO 自动生成的方法存根
		Log.i(TAG,"navi");
		Toast.makeText(getApplicationContext(),"成功开启导航",Toast.LENGTH_LONG).show();
		Boolean isSuccess= mAMapNavi.calculateWalkRoute(new NaviLatLng(lat, lon), new NaviLatLng(endlat, endlon));
		if(isSuccess==null)
			Toast.makeText(getApplicationContext(),"失败",Toast.LENGTH_LONG).show();

	}

	@Override
	public void onClick(View v) {
		// TODO 自动生成的方法存根
		mAMapNavi.calculateWalkRoute(new NaviLatLng(lat, lon), new NaviLatLng(endlat, endlon));
	}

}
