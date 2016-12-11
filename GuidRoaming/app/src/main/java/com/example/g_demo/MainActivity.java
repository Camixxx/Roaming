package com.example.g_demo;

import android.support.v7.app.ActionBarActivity;
import android.text.TextUtils;
import android.util.Log;

import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;

import org.json.JSONException;
import org.json.JSONObject;

import com.amap.api.location.AMapLocation;
import com.amap.api.location.AMapLocationClient;
import com.amap.api.maps.AMap;
import com.amap.api.maps.CameraUpdateFactory;
import com.amap.api.maps.MapView;
import com.amap.api.maps.model.BitmapDescriptor;
import com.amap.api.maps.model.BitmapDescriptorFactory;
import com.amap.api.maps.model.LatLng;
import com.amap.api.maps.model.MarkerOptions;
import com.amap.api.maps.overlay.PoiOverlay;
import com.amap.api.services.core.LatLonPoint;
import com.amap.api.services.core.PoiItem;
import com.amap.api.services.poisearch.PoiResult;
import com.amap.api.services.poisearch.PoiSearch;
import com.amap.api.services.poisearch.PoiSearch.SearchBound;
import com.iflytek.cloud.ErrorCode;
import com.iflytek.cloud.InitListener;
import com.iflytek.cloud.RecognizerListener;
import com.iflytek.cloud.RecognizerResult;
import com.iflytek.cloud.SpeechConstant;
import com.iflytek.cloud.SpeechError;
import com.iflytek.cloud.SpeechRecognizer;
import com.iflytek.cloud.SpeechUtility;
import com.iflytek.cloud.ui.RecognizerDialog;
import com.iflytek.cloud.ui.RecognizerDialogListener;
import com.iflytek.sunflower.FlowerCollector;

import Util.JsonParser;
import Util.SRController;
import Util.TTSController;
import android.app.ProgressDialog;
import android.content.Intent;
import android.graphics.BitmapFactory;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.SystemClock;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

public class MainActivity extends Base_Activity {

	private static final String TAG = "MainActivity";
	private double lat;
	private double lon;
	private double prelat;
	private double prelon;
	private boolean change=false;
	private double endlat;
	private double endlon;
	private LatLonPoint lp ;
	private LatLonPoint endlp;
	private Boolean isFlag=true;
	AMap amap;

	//双击
	long[] mHits = new long[2];
//////////////////////////////////////////////语音输入相关////////////////

	private Boolean isShowDialog=true;
	private Toast mToast;
	// 语音听写对象
	private SpeechRecognizer mIat;
	// 语音听写UI
	private RecognizerDialog mIatDialog;
	// 引擎类型
	private String mEngineType = SpeechConstant.TYPE_CLOUD;
	int ret = 0; // 函数调用返回值
	// 用HashMap存储听写结果
	private HashMap<String, String> mIatResults = new LinkedHashMap<String, String>();
	/**
	 * 初始化监听器。
	 */
	private InitListener mInitListener = new InitListener() {

		@Override
		public void onInit(int code) {
			Log.d(TAG, "SpeechRecognizer init() code = " + code);
			if (code != ErrorCode.SUCCESS) {
				showTip("初始化失败，错误码：" + code);
			}
		}
	};

	private RecognizerListener mRecognizerListener = new RecognizerListener() {

		@Override
		public void onBeginOfSpeech() {
			// 此回调表示：sdk内部录音机已经准备好了，用户可以开始语音输入
			showTip("开始说话");
		}

		@Override
		public void onError(SpeechError error) {
			// Tips：
			// 错误码：10118(您没有说话)，可能是录音机权限被禁，需要提示用户打开应用的录音权限。
			// 如果使用本地功能（语记）需要提示用户开启语记的录音权限。
			showTip(error.getPlainDescription(true));
		}

		@Override
		public void onEndOfSpeech() {
			// 此回调表示：检测到了语音的尾端点，已经进入识别过程，不再接受语音输入
			showTip("结束说话");
		}

		@Override
		public void onResult(RecognizerResult results, boolean isLast) {
			Log.d(TAG, results.getResultString());
			printResult(results);

			if (isLast) {
				// TODO 最后的结果
			}
		}

		@Override
		public void onVolumeChanged(int volume, byte[] data) {
			showTip("当前正在说话，音量大小：" + volume);
			Log.d(TAG, "返回音频数据："+data.length);
		}

		@Override
		public void onEvent(int eventType, int arg1, int arg2, Bundle obj) {
			// 以下代码用于获取与云端的会话id，当业务出错时将会话id提供给技术支持人员，可用于查询会话日志，定位出错原因
			// 若使用本地能力，会话id为null
			//	if (SpeechEvent.EVENT_SESSION_ID == eventType) {
			//		String sid = obj.getString(SpeechEvent.KEY_EVENT_SESSION_ID);
			//		Log.d(TAG, "session id =" + sid);
			//	}
		}
	};

	private void printResult(RecognizerResult results) {
		String text = JsonParser.parseIatResult(results.getResultString());

		String sn = null;
		// 读取json结果中的sn字段
		try {
			JSONObject resultJson = new JSONObject(results.getResultString());
			sn = resultJson.optString("sn");
		} catch (JSONException e) {
			e.printStackTrace();
		}

		mIatResults.put(sn, text);

		StringBuffer resultBuffer = new StringBuffer();
		for (String key : mIatResults.keySet()) {
			resultBuffer.append(mIatResults.get(key));
		}

		poitext.setText(resultBuffer.toString());
		mTtsManager.startSpeaking("输入为"+resultBuffer.toString()+"若要开始请双击开始搜索按钮");

	}
	/**
	 * 听写UI监听器
	 */
	private RecognizerDialogListener mRecognizerDialogListener = new RecognizerDialogListener() {
		public void onResult(RecognizerResult results, boolean isLast) {
			printResult(results);
		}

		/**
		 * 识别回调错误.
		 */
		public void onError(SpeechError error) {
			showTip(error.getPlainDescription(true));
		}

	};

///////////////////////////////////////////////////////////////////////////


	private AMapLocationClient mLocationClient = null;
	//按钮
	private EditText poitext;
	private Button star_Recognizer;
	private Button start_poi;
	private Button start_naiv;
	// private Button next;
	private TextView site;
	//实例化语音
	protected TTSController mTtsManager;
	// protected SRController mSRCManager;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_main);
		mMapView=(MapView)findViewById(R.id.map);
		mMapView.onCreate(savedInstanceState);
		String text = MainActivity.this.getString(R.string.app_id);
		SpeechUtility.createUtility(MainActivity.this, "appid=" + text);
		initView();


		//////////////////////////////////////////////////////////////////
		// 初始化识别无UI识别对象
		// 使用SpeechRecognizer对象，可根据回调消息自定义界面；
		mIat = SpeechRecognizer.createRecognizer(MainActivity.this, mInitListener);

		// 初始化听写Dialog，如果只使用有UI听写功能，无需创建SpeechRecognizer
		// 使用UI听写功能，请根据sdk文件目录下的notice.txt,放置布局文件和图片资源
		mIatDialog = new RecognizerDialog(MainActivity.this, mInitListener);
		////////////////////////////////////////////////////////////////

	}



	private void initView() {
		// TODO 自动生成的方法存根
		//初始化

		poitext=(EditText)findViewById(R.id.keyWord);
		star_Recognizer=(Button)findViewById(R.id.recognizerButton);
		start_naiv=(Button)findViewById(R.id.start_naiv);
		start_poi=(Button)findViewById(R.id.searchButton);
		//next=(Button)findViewById(R.id.nextButton);
		site=(TextView)findViewById(R.id.site);
		//获得地图对象
		amap=mMapView.getMap();
		//开启监听
		star_Recognizer.setOnClickListener(this);
		start_naiv.setOnClickListener(this);
		start_poi.setOnClickListener(this);
		//next.setOnClickListener(this);
		mLocationClient=super.mLocationClient;
		mLocationClient.startLocation();
		//初始化语音
		mTtsManager = TTSController.getInstance(getApplicationContext());
		mTtsManager.init();
		//mSRCManager=SRController.getInstance(getApplicationContext());
		//mSRCManager.init();
		//先初始化 防止endlp传入NAVI中的时候为空 产生错误
		endlp=new LatLonPoint(0,0);
	}

	private void searchButton() {
		// TODO 自动生成的方法存根
		if(TextUtils.isEmpty(poitext.getText())){
			mTtsManager.startSpeaking("未输入内容,无法开始搜索");
			Toast.makeText(MainActivity.this, "请输入内容", Toast.LENGTH_SHORT).show();
		}
		else{
			keyWord=poitext.getText().toString();
			doSearchQuery();
		}
	}

	/**
	 **下一页
	 *
	 private void nextButton() {
	 // TODO 自动生成的方法存根
	 if (query != null && poiSearch != null && poiResult != null) {
	 if (poiResult.getPageCount() - 1 > currentPage) {
	 currentPage++;
	 query.setPageNum(currentPage);// 设置查后一页
	 poiSearch.searchPOIAsyn();
	 } else {
	 Toast.makeText(MainActivity.this, "没有", Toast.LENGTH_SHORT).show();
	 }
	 }
	 }
	 **/

	private void doSearchQuery() {
		// TODO 自动生成的方法存根
		showProgressDialog();// 显示进度框
		currentPage = 0;
		// 第一个参数表示搜索字符串，第二个参数表示poi搜索类型，第三个参数表示poi搜索区域（空字符串代表全国）
		query = new PoiSearch.Query(keyWord, "", cityCode);
		//设置每页最多返回多少条poiitem
		query.setPageSize(20);
		// 设置查第一页
		query.setPageNum(currentPage);

		if (lp != null) {
			poiSearch = new PoiSearch(this, query);
			poiSearch.setOnPoiSearchListener(this);
			poiSearch.setBound(new SearchBound(lp, 5000, true));
			// 设置搜索区域为以lp点为圆心，其周围5000米范围
			poiSearch.searchPOIAsyn();// 异步搜索
		}
	}

	@Override
	public void onPoiSearched(PoiResult result, int rcode) {
		// TODO 自动生成的方法存根
		dissmissProgressDialog();
		mTtsManager.startSpeaking("开始搜索");
		try {
			Thread.sleep(3000);
		} catch (InterruptedException e) {
			// TODO 自动生成的 catch 块
			e.printStackTrace();
		}
		if (rcode == 1000) {
			if (result != null && result.getQuery() != null) {
				if (result.getQuery().equals(query)) {
					poiResult = result;
					//poi数据
					List<PoiItem> poiItems = poiResult.getPois();
					mTtsManager.startSpeaking("搜索到"+poiItems.size()
							+"条、、、、、默认目的地为"+poiItems.get(0).getTitle()+"、、、、"
							+"具体位置为"+poiItems.get(0).getSnippet()+"、、、、"
							+"距离为"+poiItems.get(0).getDistance()+"米 、、、、"
							+"如果要开始导航请按右侧");
					if (poiItems != null && poiItems.size() > 0) {
						amap.clear();// 清理之前的图标
						//poi图层
						PoiOverlay poiOverlay = new PoiOverlay(amap, poiItems);
						poiOverlay.removeFromMap();
						poiOverlay.addToMap();
						poiOverlay.zoomToSpan();
						endlp=poiItems.get(0).getLatLonPoint();
					}  else {
						Toast.makeText(MainActivity.this, "无结果", Toast.LENGTH_SHORT).show();
					}
				}
			}
		}
		else {
			Toast.makeText(MainActivity.this, "错误", Toast.LENGTH_SHORT).show();
		}
	}

	@Override
	public void onLocationChanged(AMapLocation  amapLocation) {
		if (amapLocation != null) {
			if (amapLocation.getErrorCode() == 0) {
				Log.i(TAG,"定位成功");
				lat = amapLocation.getLatitude();
				lon = amapLocation.getLongitude();
				if(prelat!=lat||prelon!=lon){
					change=true;
					prelat=lat;
					prelon=lon;
				}
				if(change){
					mTtsManager.startSpeaking("当前位置为"+amapLocation.getCity()+"、"
							+amapLocation.getAoiName());
					change=false;
				}

				lp = new LatLonPoint(lat, lon);
				cityCode=amapLocation.getCity();
				amap.clear();
				amap.moveCamera(CameraUpdateFactory.newLatLngZoom(new LatLng(lat, lon), 19));
				MarkerOptions markerOptions = new MarkerOptions();
				markerOptions.position(new LatLng(lat, lon));
				markerOptions.title("当前位置");
				markerOptions.visible(true);
				BitmapDescriptor bitmapDescriptor = BitmapDescriptorFactory.fromBitmap(BitmapFactory.decodeResource(getResources(), R.drawable.ma_pass));
				markerOptions.icon(bitmapDescriptor);
				amap.addMarker(markerOptions);
				site.setText("  "+amapLocation.getCity()+"  "
						+amapLocation.getAoiName()+"  "
						+amapLocation.getAdCode());
			}
			else{
				Log.e("AmapError", "location Error, ErrCode:"
						+ amapLocation.getErrorCode() + ", errInfo:"
						+ amapLocation.getErrorInfo());

				Toast.makeText(getApplicationContext(), "定位失败"+ amapLocation.getErrorCode(), Toast.LENGTH_LONG).show();
			}
		}

	}


	@Override
	public void onClick(View v) {
		// TODO 自动生成的方法存根

		System.arraycopy(mHits, 1, mHits, 0, mHits.length - 1);
		mHits[mHits.length - 1] = SystemClock.uptimeMillis();
		//双击事件的时间间隔500ms
		if (mHits[0] >= (SystemClock.uptimeMillis() - 500)) {
			//双击后具体的操作
			//do
			doubleClick(v);
		}
		else
		{
			switch(v.getId()){
				case R.id.start_naiv:
					mTtsManager.startSpeaking("开始导航按钮");
					break;
				case R.id.recognizerButton:
					mTtsManager.startSpeaking("语音输入按钮");
					break;
				case R.id.searchButton:
					mTtsManager.startSpeaking("开 始搜索按钮");
					break;
			/*case R.id.nextButton:
				nextButton();
				break;
			*/
			}
		}


	}

	private void doubleClick(View v) {
		// TODO 自动生成的方法存根
		switch(v.getId()){

			case R.id.start_naiv:
				mTtsManager.startSpeaking("确认开始导航，正在规划、、");
				try {
					Thread.sleep(2000);
				} catch (InterruptedException e) {
					// TODO 自动生成的 catch 块
					e.printStackTrace();
				}

				Intent itent=new Intent(MainActivity.this,Navi.class);
				itent.putExtra("startlat", lat);
				itent.putExtra("startlon", lon);
				itent.putExtra("endlat", endlp.getLatitude());
				itent.putExtra("endlon", endlp.getLongitude());
				startActivity(itent);
				break;
			case R.id.recognizerButton:
				this.poitext.setText(null);
				//mTtsManager.startSpeaking("开始进行语音输入，请一秒后开始输入");
			/*try {
				Thread.sleep(6000);
			} catch (InterruptedException e) {
				// TODO 自动生成的 catch 块
				e.printStackTrace();
			}*/
				RecognizerButton();
				break;
			case R.id.searchButton:
				searchButton();
				break;
		/*case R.id.nextButton:
			nextButton();
			break;
		*/
		}
	}



	@Override
	public void onMapClick(LatLng arg0) {
		// TODO 自动生成的方法存根
		Log.i(TAG,"定位成功");
		amap.moveCamera(CameraUpdateFactory.changeLatLng(arg0));
	}

/////////////////////////////////////语音相关/////////////////////////////////////////


	private void RecognizerButton() {
		// TODO 自动生成的方法存根
		FlowerCollector.onEvent(MainActivity.this, "iat_recognize");
		this.poitext.setText(null);
		mIatResults.clear();
		setParam();
		if (isShowDialog) {
			// 显示听写对话框
			mIatDialog.setListener(mRecognizerDialogListener);
			mTtsManager.startSpeaking("开始输入");
			mIatDialog.show();
		} else {
			// 不显示听写对话框
			ret = mIat.startListening(mRecognizerListener);
			if (ret != ErrorCode.SUCCESS) {
				showTip("听写失败,错误码：" + ret);
			} else {

			}
		}
	}


	private void showTip(String str) {
		// TODO 自动生成的方法存根
		mToast.setText(str);
		mToast.show();
	}

	private void setParam() {
		// TODO 自动生成的方法存根
		// 设置听写引擎
		mIat.setParameter(SpeechConstant.ENGINE_TYPE, mEngineType);
		// 设置返回结果格式
		mIat.setParameter(SpeechConstant.RESULT_TYPE, "json");
		mIat.setParameter(SpeechConstant.LANGUAGE, "zh_cn");
		mIat.setParameter(SpeechConstant.DOMAIN,"iat");
		mIat.setParameter(SpeechConstant.ACCENT,"mandarin");
		// 设置标点符号,设置为"0"返回结果无标点,设置为"1"返回结果有标点
		mIat.setParameter(SpeechConstant.ASR_PTT, "0");
	}
	@Override
	protected void onDestroy() {
		super.onDestroy();
		// 退出时释放连接
		mIat.cancel();
		mIat.destroy();
	}


}