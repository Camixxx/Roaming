package com.example.g_demo;

import java.util.List;

import com.amap.api.location.AMapLocation;
import com.amap.api.location.AMapLocationClient;
import com.amap.api.location.AMapLocationClientOption;
import com.amap.api.location.AMapLocationListener;
import com.amap.api.location.AMapLocationClientOption.AMapLocationMode;
import com.amap.api.maps.AMap;
import com.amap.api.maps.CameraUpdateFactory;
import com.amap.api.maps.MapView;
import com.amap.api.maps.model.LatLng;
import com.amap.api.services.core.PoiItem;
import com.amap.api.services.geocoder.GeocodeResult;
import com.amap.api.services.geocoder.GeocodeSearch.OnGeocodeSearchListener;
import com.amap.api.services.geocoder.RegeocodeResult;
import com.amap.api.services.poisearch.PoiResult;
import com.amap.api.services.poisearch.PoiSearch;
import com.amap.api.services.poisearch.PoiSearch.OnPoiSearchListener;
import com.amap.api.services.route.BusRouteResult;
import com.amap.api.services.route.DriveRouteResult;
import com.amap.api.services.route.RideRouteResult;
import com.amap.api.services.route.RouteSearch.OnRouteSearchListener;
import com.amap.api.services.route.WalkRouteResult;
import com.amap.api.maps.LocationSource.OnLocationChangedListener;

import android.app.Activity;
import android.app.ProgressDialog;
import android.os.Bundle;
import android.support.v7.app.ActionBarActivity;
import android.view.View;
import android.view.View.OnClickListener;

public class Base_Activity extends Activity implements OnClickListener,AMapLocationListener,AMap.OnMapClickListener ,OnPoiSearchListener,OnRouteSearchListener{

	protected MapView mMapView ;
	// 要输入的poi搜索关键字
	protected String keyWord = "";
	// 城市
	protected String cityCode = "北京";
	// 搜索时进度条
	private ProgressDialog progDialog = null;
	// poi返回的结果
	protected PoiResult poiResult;
	// 当前页面，从0开始计数
	protected int currentPage = 0;
	// Poi查询条件类
	protected PoiSearch.Query query;
	// POI搜索
	protected PoiSearch poiSearch;



	//声明AMapLocationClient类对象
	//定位发起端
	AMapLocationClient mLocationClient = null;
	//定位参数/** 声明mLocationOption对象 */
	AMapLocationClientOption mLocationOption = null;
	//定位监听器
	OnLocationChangedListener mListener = null;


	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		initLoction();
	}

	public void initLoction() {
		// TODO 自动生成的方法存根
		mLocationClient=new AMapLocationClient(this);
		mLocationOption=new AMapLocationClientOption();
		mLocationClient.setLocationListener(this);
		//设置定位模式为高精度模式，Battery_Saving为低功耗模式，Device_Sensors是仅设备模式
		mLocationOption.setLocationMode(AMapLocationMode.Hight_Accuracy);
		//设置定位间隔,单位毫秒,默认为2000ms
		mLocationOption.setInterval(36000);
		//设置是否只定位一次,默认为false
		mLocationOption.setOnceLocation(false);
		//设置是否返回地址信息（默认返回地址信息）
		mLocationOption.setNeedAddress(true);
		//设置是否强制刷新WIFI，默认为强制刷新
		mLocationOption.setWifiActiveScan(true);
		//设置是否允许模拟位置,默认为false，不允许模拟位置
		mLocationOption.setMockEnable(false);
		//给定位客户端对象设置定位参数
		mLocationClient.setLocationOption(mLocationOption);
		//启动定位
		mLocationClient.startLocation();
	}

	/**
	 * 显示进度框
	 */
	protected void showProgressDialog() {
		if (progDialog == null)
			progDialog = new ProgressDialog(this);
		progDialog.setProgressStyle(ProgressDialog.STYLE_SPINNER);
		progDialog.setIndeterminate(false);
		progDialog.setCancelable(false);
		progDialog.setMessage("正在搜索:\n" + keyWord);
		progDialog.show();
	}

	/**
	 * 隐藏进度框
	 */
	protected void dissmissProgressDialog() {
		if (progDialog != null) {
			progDialog.dismiss();
		}
	}

	/**
	 * 将poi搜索到的信息通过TTF读出来（默认第一条）
	 */
	protected void ReadInformation(PoiItem poiItem) {
		poiItem.getTitle();
		//获得片段
		poiItem.getSnippet();
		//获得Name
		poiItem.getDistance();
	}


	@Override
	protected void onResume() {
		super.onResume();;
		//在activity执行onDestroy时执行mMapView.onDestroy()，实现地图生命周期管理
		mMapView.onResume();;
	}

	@Override
	protected void onDestroy() {
		super.onDestroy();
		//在activity执行onDestroy时执行mMapView.onDestroy()，实现地图生命周期管理
		mMapView.onDestroy();
	}

	@Override
	protected void onPause() {
		super.onPause();
		//在activity执行onPause时执行mMapView.onPause ()，实现地图生命周期管理
		mMapView.onPause();
	}

	@Override
	public void onLocationChanged(AMapLocation arg0) {
		// TODO 自动生成的方法存根

	}

	@Override
	public void onClick(View v) {
		// TODO 自动生成的方法存根

	}

	@Override
	public void onMapClick(LatLng arg0) {
		// TODO 自动生成的方法存根

	}

	@Override
	public void onPoiItemSearched(PoiItem arg0, int arg1) {
		// TODO 自动生成的方法存根

	}

	@Override
	public void onPoiSearched(PoiResult result, int rcode) {
		// TODO 自动生成的方法存根

	}

	@Override
	public void onBusRouteSearched(BusRouteResult arg0, int arg1) {
		// TODO 自动生成的方法存根

	}

	@Override
	public void onDriveRouteSearched(DriveRouteResult arg0, int arg1) {
		// TODO 自动生成的方法存根

	}

	@Override
	public void onRideRouteSearched(RideRouteResult arg0, int arg1) {
		// TODO 自动生成的方法存根

	}

	@Override
	public void onWalkRouteSearched(WalkRouteResult arg0, int arg1) {
		// TODO 自动生成的方法存根

	}


}
