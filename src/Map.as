//---------------------------------------------------------
//Description:
//
//Modify:
//    2014-10-27 create by Gavin
//
//---------------------------------------------------------
package
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	import flash.utils.Timer;

	[SWF(width=900,height=600)]
	public class Map extends MovieClip
	{
		public function Map()
		{
			createMaps();
			roadMens();
			roadTimer = new Timer(80, 0); //定义计时器以完成寻路人行走动画
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDowns);
		}

		private function keyDowns(evt:KeyboardEvent):void
		{
			if (evt.keyCode == Keyboard.SPACE)
			{
				removeChild(map);
				mapArr = [];
				createMaps();
				roadMens(); //生成寻路人
				roadTimer.stop();
			} 
		}

		private function roadMens():void
		{
			roadMen = drawRect(2);
			//让寻路人随机出现在地图上并设置寻路人的横纵向索引位置----->
			var _tmpx:uint = Math.round(Math.random() * (w - 1));
			var _tmpy:uint = Math.round(Math.random() * (h - 1));
			roadMen.px = _tmpx; //记录所在位置索引值
			roadMen.py = _tmpy;
			roadMen.x = _tmpx * wh;
			roadMen.y = _tmpy * wh;
			mapArr[_tmpy][_tmpx].go = 0; //让寻路人出现的地图点变为可通过
			map.addChild(roadMen);
		}

		private var wh:int = 9;
		private var map:Sprite;
		private var mapArr:Array = [];
		private var goo:Number = 0.3;
		private var w:int = 98;
		private var h:int = 60;
		private var roadList:Array;
		private var roadTimer:Timer;
		private var roadMen:MovieClip;
		private var timer_i:uint = 0;
		private  var roadinf:TextField;
		private var roadLen:TextField;

		private function createMaps():void
		{
			map = new Sprite; //地图容器
			map.x = wh;
			map.y = wh;
			addChild(map);
			map.addEventListener(MouseEvent.MOUSE_DOWN, mapMousedown); //鼠标点击地图事件
			for (var y:uint = 0; y < h; y++)
			{
				mapArr[y] = []; //建立二维数组存储地图信息
				for (var x:uint = 0; x < w; x++)
				{
					var mapPoint:uint = Math.round(Math.random() - goo); //随机节点可通过与不可通过
					var point:MovieClip = drawRect(mapPoint); //画出节点
					mapArr[y].push(point); //将节点加入地图数组中
					mapArr[y][x].px = x; //当前节点横向索引位置
					mapArr[y][x].py = y; //当前节点纵向索引位置
					mapArr[y][x].go = mapPoint; //当前节点是否可通过
					mapArr[y][x].x = x * wh; //当前节点的x位置
					mapArr[y][x].y = y * wh; //当前节点的y位置
					map.addChild(mapArr[y][x]); //将节点显示到地图容器中
				} //End for x
			} //End for y
		} //End fun 

		private function goMap(evt:TimerEvent):void
		{
			var tmpMC:MovieClip = roadList[timer_i];
			roadMen.x = tmpMC.x;
			roadMen.y = tmpMC.y;
			tmpMC.alpha = 1; //经过路径后消除其标识状态
			timer_i++;
			//达到终点行走停止
			if (timer_i >= roadList.length)
			{
				roadTimer.stop();
			}
		}

		private function mapMousedown(evt:MouseEvent):void
		{
			var endX:Number = Math.floor((mouseX - map.x) / wh); //将鼠标点击位置转化为节点索引值
			var endY:Number = Math.floor((mouseY - map.y) / wh); //将鼠标点击位置转化为节点索引值
			var endPoint:MovieClip = mapArr[endY][endX]; //从地图中取出鼠标点击的节点作为寻路终点
			//如果目的地是可通过的则开始寻路
			if (endPoint.go == 0)
			{
				//每次寻路开始前将上次的路径清空
				if (roadList)
				{
					for each (var mc:MovieClip in roadList)
					{
						mc.alpha = 1;
					}
					roadList = [];
				}
				roadTimer.stop(); //停止走路
				//动态取得寻路人当前位置的索引，并更新
				roadMen.px = Math.floor(roadMen.x / wh);
				roadMen.py = Math.floor(roadMen.y / wh);
				var _ARoad:ARoad = new ARoad(); //生成寻路实例
				var oldTimes:int = new Date().getTime(); //记录发送寻路方法时间
				roadList = _ARoad.searchRoad(roadMen, endPoint, mapArr); //调用寻路方法（寻路人，目的地，地图信息）
				var times:int = new Date().getTime() - oldTimes; //寻路方法执行完毕计算寻路花费时间
				if (roadList.length > 0)
				{
//					roadinf.htmlText = "本次寻路<FONT color='#00ff00'>" + times.toString() + "</FONT> 毫秒";
//					roadLen.htmlText = "路径长度：<FONT color='#00ff00'>" + roadList.length.toString() + "</FONT>"; //路径长度
					MC_play(roadList); //让寻路人行走
				}
				else
				{
//					roadinf.htmlText = "对不起，无路可走";
				}
			}
		}

		private function MC_play(roadList:Array):void
		{
			roadList.reverse(); //倒转数组
			roadTimer.stop();
			timer_i = 0;
			roadTimer.addEventListener(TimerEvent.TIMER, goMap);
			roadTimer.start();
			for each (var mc:MovieClip in roadList)
			{
				mc.alpha = 0.3;
			}
		}

		//根据传入的随机数画出不同的节点（即可通过/不可通过/寻路人）－－－》
		private function drawRect(mapPoint:uint):MovieClip
		{
			var _tmp:MovieClip = new MovieClip;
			var color:uint;
			switch (mapPoint)
			{
				case 0:
					color = 0x999999; //可通过为灰色
					break;
				case 1:
					color = 0x000000; //不可通过为黑色
					break;
				default:
					color = 0xFF0000; //否则为寻路人
			} 
			_tmp.graphics.beginFill(color);
			_tmp.graphics.lineStyle(0.2, 0xFFFFFF);
			_tmp.graphics.drawRect(0, 0, wh, wh);
			_tmp.graphics.endFill();
			return _tmp;
		}
	}

}
