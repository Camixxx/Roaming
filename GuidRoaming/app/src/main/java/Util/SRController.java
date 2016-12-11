package Util;


import android.app.Activity;
import android.content.Context;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.os.Environment;
import android.util.Log;
import android.widget.EditText;
import android.widget.Toast;

import java.util.HashMap;
import java.util.LinkedHashMap;

import org.json.JSONException;
import org.json.JSONObject;

import com.amap.api.navi.AMapNaviListener;
import com.amap.api.navi.model.AMapLaneInfo;
import com.amap.api.navi.model.AMapNaviCross;
import com.amap.api.navi.model.AMapNaviInfo;
import com.amap.api.navi.model.AMapNaviLocation;
import com.amap.api.navi.model.AMapNaviStaticInfo;
import com.amap.api.navi.model.AMapNaviTrafficFacilityInfo;
import com.amap.api.navi.model.AimLessModeCongestionInfo;
import com.amap.api.navi.model.AimLessModeStat;
import com.amap.api.navi.model.NaviInfo;
import com.autonavi.tbt.NaviStaticInfo;
import com.autonavi.tbt.TrafficFacilityInfo;
import com.example.g_demo.R;
import com.iflytek.cloud.ErrorCode;
import com.iflytek.cloud.InitListener;
import com.iflytek.cloud.RecognizerListener;
import com.iflytek.cloud.RecognizerResult;
import com.iflytek.cloud.SpeechConstant;
import com.iflytek.cloud.SpeechError;
import com.iflytek.cloud.SpeechRecognizer;
import com.iflytek.cloud.SpeechSynthesizer;
import com.iflytek.cloud.SpeechUtility;
import com.iflytek.cloud.SynthesizerListener;
import com.iflytek.cloud.ui.RecognizerDialog;
import com.iflytek.cloud.ui.RecognizerDialogListener;

/**
 * 语音听写组件
 */
public class SRController  {
	private static String TAG = SRController.class.getSimpleName();

	private Context mContext;
	private static SRController ttsManager;
	private Toast mToast;
	private String mResultText;
	//是否显示图标
	private Boolean isShow=true;
	// 语音听写对象
	private SpeechRecognizer mlat;
	// 语音听写UI
	private RecognizerDialog mIatDialog;
	// 用HashMap存储听写结果
	private HashMap<String, String> mIatResults = new LinkedHashMap<String, String>();
	/**
	 * 初始化监听。
	 */
	private InitListener mlatInitListener = new InitListener() {
		@Override
		public void onInit(int code) {
			Log.d("SHIXIN", "InitListener init() code = " + code);
			if (code != ErrorCode.SUCCESS) {
				Toast.makeText(mContext, "初始化失败,错误码：" + code, Toast.LENGTH_SHORT).show();
			} else {
				// 初始化成功，之后可以调用startSpeaking方法
				// 注：有的开发者在onCreate方法中创建完合成对象之后马上就调用startSpeaking进行合成，
				// 正确的做法是将onCreate中的startSpeaking调用移至这里
			}
		}
	};

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

	/**
	 * 听写监听器
	 */
	private RecognizerListener mRecognizerListener =new RecognizerListener(){

		@Override
		public void onBeginOfSpeech() {
			// TODO 自动生成的方法存根
			showTip("开始说话");
		}

		@Override
		public void onEndOfSpeech() {
			// TODO 自动生成的方法存根
			showTip("结束说话");
		}

		@Override
		public void onError(SpeechError error) {
			// TODO 自动生成的方法存根
			error.getPlainDescription(true); //获取错误码描述
		}

		@Override
		public void onEvent(int arg0, int arg1, int arg2, Bundle arg3) {
			// TODO 自动生成的方法存根
			// 以下代码用于获取与云端的会话id，当业务出错时将会话id提供给技术支持人员，可用于查询会话日志，定位出错原因
			// 若使用本地能力，会话id为null
			//	if (SpeechEvent.EVENT_SESSION_ID == eventType) {
			//		String sid = obj.getString(SpeechEvent.KEY_EVENT_SESSION_ID);
			//		Log.d(TAG, "session id =" + sid);
			//	}
		}

		@Override
		public void onResult(RecognizerResult results , boolean arg1) {
			// TODO 自动生成的方法存根
			Log.d("Result:",results.getResultString ());
			printResult(results);
		}

		@Override
		public void onVolumeChanged(int volume, byte[] data) {
			// TODO 自动生成的方法存根
			showTip("当前正在说话，音量大小：" + volume);
			Log.d(TAG, "返回音频数据："+data.length);
		}
	};
//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////

	private SRController(Context context) {
		mContext = context;
	}

	public static SRController getInstance(Context context) {
		if (ttsManager == null) {
			ttsManager = new SRController(context);
		}
		return ttsManager;
	}


	/**
	 * 初始化
	 */

	public void init() {

		// 初始化合成对象.
		mlat=SpeechRecognizer.createRecognizer(mContext, mlatInitListener);
		mIatDialog=new RecognizerDialog(mContext,mlatInitListener);
		/**
		 * 参数设置
		 */
		initSpeechSynthesizer();

	}

	/**
	 * 使用SpeechSynthesizer合成语音，不弹出合成Dialog.
	 *
	 * @param
	 */
	public void startListening() {
		// 进行语音合成.
		if(this.isShow=true){
			mResultText=null;
			mIatDialog.setListener(mRecognizerDialogListener);
			mIatDialog.show();
		}
		else{
			if (mlat != null){
				mResultText=null;
				mlat.startListening(mRecognizerListener);
			}
		}
	}


	public void stopListening() {
		if (mlat != null)
			mlat.stopListening();

	}

	/**
	 * 参数设置
	 */
	private void initSpeechSynthesizer() {
		// 清空参数
		mlat.setParameter(SpeechConstant.DOMAIN,"iat");
		mlat.setParameter(SpeechConstant.LANGUAGE,"zh_cn");
		mlat.setParameter(SpeechConstant.ACCENT,"mandarin");
		// 设置返回结果格式
		mlat.setParameter(SpeechConstant.RESULT_TYPE, "json");
	}

	public void destroy() {
		if (mlat != null) {
			mlat.stopListening();
			mlat.destroy();
			ttsManager=null;
		}
	}

	private void showTip(final String str) {
		mToast.setText(str);
		mToast.show();
	}

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

		mResultText=resultBuffer.toString();
	}

	public String getString(){
		return mResultText;
	}

	private void setIsShow(Boolean initisShow){
		this.isShow=initisShow;
	}

}