package com.example.g_demo;

import com.amap.api.location.AMapLocation;
import com.amap.api.location.AMapLocationClient;
import com.amap.api.location.AMapLocationClientOption;
import com.amap.api.location.AMapLocationListener;
import com.amap.api.location.AMapLocationClientOption.AMapLocationMode;
import com.amap.api.maps.MapView;
import com.amap.api.maps.LocationSource.OnLocationChangedListener;
import com.amap.api.navi.AMapNavi;
import com.amap.api.navi.AMapNaviListener;
import com.amap.api.navi.AMapNaviView;
import com.amap.api.navi.AMapNaviViewListener;
import com.amap.api.navi.model.AMapLaneInfo;
import com.amap.api.navi.model.AMapNaviCross;
import com.amap.api.navi.model.AMapNaviInfo;
import com.amap.api.navi.model.AMapNaviLocation;
import com.amap.api.navi.model.AMapNaviStaticInfo;
import com.amap.api.navi.model.AMapNaviTrafficFacilityInfo;
import com.amap.api.navi.model.AimLessModeCongestionInfo;
import com.amap.api.navi.model.AimLessModeStat;
import com.amap.api.navi.model.NaviInfo;
import com.amap.api.navi.model.NaviLatLng;
import com.amap.api.navi.view.RouteOverLay;
import com.autonavi.tbt.NaviStaticInfo;
import com.autonavi.tbt.TrafficFacilityInfo;

import android.app.Activity;
import android.os.Bundle;
import android.support.v7.app.ActionBarActivity;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Toast;

public class Base_Navi extends Activity implements OnClickListener,AMapNaviViewListener, AMapNaviListener{

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

	}



	@Override
	public void OnUpdateTrafficFacility(AMapNaviTrafficFacilityInfo arg0) {
		// TODO 自动生成的方法存根

	}

	@Override
	public void OnUpdateTrafficFacility(TrafficFacilityInfo arg0) {
		// TODO 自动生成的方法存根

	}

	@Override
	public void OnUpdateTrafficFacility(AMapNaviTrafficFacilityInfo[] arg0) {
		// TODO 自动生成的方法存根

	}

	@Override
	public void hideCross() {
		// TODO 自动生成的方法存根

	}

	@Override
	public void hideLaneInfo() {
		// TODO 自动生成的方法存根

	}

	@Override
	public void notifyParallelRoad(int arg0) {
		// TODO 自动生成的方法存根

	}

	@Override
	public void onArriveDestination() {
		// TODO 自动生成的方法存根

	}

	@Override
	public void onArriveDestination(NaviStaticInfo arg0) {
		// TODO 自动生成的方法存根

	}

	@Override
	public void onArriveDestination(AMapNaviStaticInfo arg0) {
		// TODO 自动生成的方法存根

	}

	@Override
	public void onArrivedWayPoint(int arg0) {
		// TODO 自动生成的方法存根

	}

	@Override
	public void onCalculateMultipleRoutesSuccess(int[] arg0) {
		// TODO 自动生成的方法存根

	}

	@Override
	public void onCalculateRouteFailure(int arg0) {
		// TODO 自动生成的方法存根

	}

	@Override
	public void onCalculateRouteSuccess() {
		// TODO 自动生成的方法存根

	}

	@Override
	public void onEndEmulatorNavi() {
		// TODO 自动生成的方法存根

	}

	@Override
	public void onGetNavigationText(int arg0, String arg1) {
		// TODO 自动生成的方法存根

	}

	@Override
	public void onGpsOpenStatus(boolean arg0) {
		// TODO 自动生成的方法存根

	}

	@Override
	public void onInitNaviFailure() {
		// TODO 自动生成的方法存根

	}

	@Override
	public void onInitNaviSuccess() {
		// TODO 自动生成的方法存根

	}

	@Override
	public void onLocationChange(AMapNaviLocation arg0) {
		// TODO 自动生成的方法存根

	}

	@Override
	public void onNaviInfoUpdate(NaviInfo arg0) {
		// TODO 自动生成的方法存根

	}

	@Override
	public void onNaviInfoUpdated(AMapNaviInfo arg0) {
		// TODO 自动生成的方法存根

	}

	@Override
	public void onReCalculateRouteForTrafficJam() {
		// TODO 自动生成的方法存根

	}

	@Override
	public void onReCalculateRouteForYaw() {
		// TODO 自动生成的方法存根

	}

	@Override
	public void onStartNavi(int arg0) {
		// TODO 自动生成的方法存根

	}

	@Override
	public void onTrafficStatusUpdate() {
		// TODO 自动生成的方法存根

	}

	@Override
	public void showCross(AMapNaviCross arg0) {
		// TODO 自动生成的方法存根

	}

	@Override
	public void showLaneInfo(AMapLaneInfo[] arg0, byte[] arg1, byte[] arg2) {
		// TODO 自动生成的方法存根

	}

	@Override
	public void updateAimlessModeCongestionInfo(AimLessModeCongestionInfo arg0) {
		// TODO 自动生成的方法存根

	}

	@Override
	public void updateAimlessModeStatistics(AimLessModeStat arg0) {
		// TODO 自动生成的方法存根

	}

	@Override
	public void onLockMap(boolean arg0) {
		// TODO 自动生成的方法存根

	}

	@Override
	public boolean onNaviBackClick() {
		// TODO 自动生成的方法存根
		return false;
	}

	@Override
	public void onNaviCancel() {
		// TODO 自动生成的方法存根

	}

	@Override
	public void onNaviMapMode(int arg0) {
		// TODO 自动生成的方法存根

	}

	@Override
	public void onNaviSetting() {
		// TODO 自动生成的方法存根

	}

	@Override
	public void onNaviTurnClick() {
		// TODO 自动生成的方法存根

	}

	@Override
	public void onNaviViewLoaded() {
		// TODO 自动生成的方法存根

	}

	@Override
	public void onNextRoadClick() {
		// TODO 自动生成的方法存根

	}

	@Override
	public void onScanViewButtonClick() {
		// TODO 自动生成的方法存根

	}

	@Override
	public void onClick(View v) {
		// TODO 自动生成的方法存根

	}

}


