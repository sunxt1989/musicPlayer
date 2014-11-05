package modules.samsung
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.net.URLRequest;
	import flash.external.ExternalInterface;
	
	
	//构造函数
	public class musicPlayer extends MovieClip
	{	
		private var song:SoundChannel;
		private var soundFactory:Sound;
		//三个按钮
		private var aPlayButton:Object;
		private var aPauseButton:Object;
		private var aStopButton:Object;
		//时间控制变量
		private var sdlen:Number;
		private var nowlen:Number;
		private var playing:Number;
		private var position:Number;
		//进度条鼠标点击百分比
		private var progressFraction:Number;
	 	private var X:Number;
		private var totalX:Number;
		private var BallX:Number=-110;	//小球起始位置
		
		//JS接口
		public function playSong(url:String,musicName:String,musicAuthor:String):void
		{
			if(soundFactory != null){
				song.stop();
				//soundFactory.close();		
			}
			this.mouseChildren=true;
			var request:URLRequest = new URLRequest(url);
			soundFactory = new Sound();
			soundFactory.load(request);
			song = soundFactory.play();
			mp3Name.text=musicName;
			mp3Author.text=musicAuthor;
			
		}
		/* 
		*测试用
		//xxx
		private function xxx(e:MouseEvent):void
		{
			playSong("a.mp3","你好吗","王力宏");
		}
		*/
		//构造函数
		public function musicPlayer():void
		{
			ExternalInterface.addCallback("playSong", playSong);
			//测试接口用按钮
			//xxxbtn.addEventListener(MouseEvent.CLICK,xxx);
			
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		//初始化
		private function init(e:Event = null):void
		{			
			
			//未传入参数时 鼠标不可点击flash	
			this.mouseChildren=false;
		
			//定义按钮别名
			aPlayButton = this.playbtn;
			aPauseButton = this.pausebtn;
			aStopButton = this.stopbtn;
			
			//初始化按钮显示状态
			aPlayButton.visible=false;
			aPauseButton.visible=true;
			
			//按钮添加侦听鼠标单击事件
			progressBar.buttonMode=true;
			aPlayButton.addEventListener(MouseEvent.CLICK,clickPlayButton);
			aStopButton.addEventListener(MouseEvent.CLICK, clickStopButton);
			aPauseButton.addEventListener(MouseEvent.CLICK,clickPauseButton);
			
			
			addEventListener(Event.ENTER_FRAME, Bar);
			//在进度条上侦听鼠标单击事件
			progressBar.progressTrack.addEventListener(MouseEvent.MOUSE_DOWN,MouseDown);
			progressBar.progressBall.addEventListener(MouseEvent.MOUSE_DOWN,MouseDown);
			//playSong("http://listen.idj.126.net/kf/437/fea52d71d7f649c78e5196d97fa0c07f.mp3","第二首","王丽红红");
		}
		
		//进度条上侦听鼠标事件
		private function MouseDown(event:MouseEvent):void
		{
			stage.addEventListener(MouseEvent.MOUSE_UP,MouseUp);
			addEventListener(Event.ENTER_FRAME, progressX);
		}
		//进度条鼠标抬起
		private function MouseUp(event:MouseEvent):void
		{
			//老歌停止
			song.stop();
			removeEventListener(Event.ENTER_FRAME, progressX);
			stage.removeEventListener(MouseEvent.MOUSE_UP,MouseUp);
			position=progressFraction * (soundFactory.length*(soundFactory.bytesTotal/soundFactory.bytesLoaded));
			
			//判断点击/拖动滚动条以前的状态，如果之前为播放按钮为隐藏状态，则播放，否则只显示进度条（但不播放）。
			if(playbtn.visible==false){doPlay();}
			else{
					if(progressBar.progressTrack.mouseX<progressBar.progressBG.width){
					progressBar.progressPlaying.width=progressBar.progressTrack.mouseX;}
					nowInfoText.text = timeConversion(progressFraction * (soundFactory.length*(soundFactory.bytesTotal/soundFactory.bytesLoaded)));
					removeEventListener(Event.ENTER_FRAME, Bar);
				}
			
		}
		
		
		
		//进度条进度控制
		private function progressX(e:Event):void
		{
			//只有用户单击进度条时的鼠标位置小于整个进度条长度才可以引起变化
			if(progressBar.progressTrack.mouseX<progressBar.progressBG.width){
			progressBar.progressPlaying.width=progressBar.progressTrack.mouseX;
			progressBar.progressBall.x=progressBar.progressPlaying.width+BallX;}
			nowInfoText.text = timeConversion(progressFraction * (soundFactory.length*(soundFactory.bytesTotal/soundFactory.bytesLoaded)));
		
			totalX=progressBar.progressTrack.width;
			
			/*如果用户鼠标拖拉到进度条之前，那么进度为0，
			如果用户鼠标拖拉到进度条之后，那么进度为最大。*/
			if(progressBar.progressTrack.mouseX<0){X=0;}
			else if(progressBar.progressTrack.mouseX>progressBar.progressTrack.width){
				X=progressBar.progressTrack.width;}
			else{X=progressBar.progressTrack.mouseX;}
			//用户鼠标的位置与整个进度条之比	
			progressFraction=X/progressBar.progressBG.width;
		}
		
		
		//单击播放按钮时触发doPlay()函数
		private function clickPlayButton(event:MouseEvent):void
		{
			doPlay();
		}
		//单击暂停按钮时触发doPause()函数
		private function clickPauseButton(event:MouseEvent):void
		{
			doPause();
		}
		//单击停止按钮时触发doStop()函数，同时改变播放暂停按钮的状态
		private function clickStopButton(event:MouseEvent):void
		{
			doStop();
			aPlayButton.visible=true;
			aPauseButton.visible=false;
		}
		//播放函数
		/*触发进度条改变事件，改变播放暂停按钮状态，从当前位置开始播放*/
		private function doPlay():void
		{
			addEventListener(Event.ENTER_FRAME, Bar);
			aPlayButton.visible=false;
			aPauseButton.visible=true;
			song=soundFactory.play(position);
		}
		//暂停函数
		/*改变播放暂停按钮状态，将播放位置存储，停止声音播放*/
		private function doPause():void
		{
			aPlayButton.visible=true;
			aPauseButton.visible=false;
			position=song.position;
			song.stop();
		}
		//停止
		/*移除进度条移动函数，停止播放声音，重置播放位置为0，重置文字为00:00，重置播放条为0，重置小球到起始位置*/
		private function doStop():void
		{
			removeEventListener(Event.ENTER_FRAME, Bar);
			song.stop();
			position=0;
			nowInfoText.text = "00:00"
			progressBar.progressPlaying.scaleX=0;
			progressBar.progressBall.x=0+BallX;
			
		}
		//播放条
		/*如果加载了歌曲，那么进度随歌曲进度变化，如果鼠标单击的位置大于当前播放的位置，则显示正在缓冲*/
		private function Bar(e:Event):void
		{
			if(song!=null){
				position=song.position;
				sdlen = soundFactory.length;
				nowlen = position;
				playing = nowlen/(sdlen * (soundFactory.bytesTotal/soundFactory.bytesLoaded));
				setBarPlaying(playing); 
				progressBar.progressLoaded.scaleX = soundFactory.bytesLoaded/soundFactory.bytesTotal;
				if(progressBar.progressPlaying.width<=progressBar.progressLoaded.width){
				nowInfoText.text = timeConversion(nowlen);}
				else{nowInfoText.text="正在缓冲";}
			}
		}
		//播放条进度控制
		private function setBarPlaying(value:Number){
			progressBar.progressPlaying.scaleX = value;
			progressBar.progressBall.x=progressBar.progressPlaying.width+BallX;
		}
		//时间格式转换函数
		private function timeConversion(times:Number):String
		{
			var min:String = String(Math.floor(times/1000/60));
			min = Number(min)<10? '0'+min:min;
			var sec:String = String(Math.round(times/1000%60));
			sec = Number(sec)<10? '0'+sec:sec;
			return min + ':' + sec;
		}
	}
}