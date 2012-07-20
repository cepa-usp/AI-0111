package 
{
	import BaseAssets.BaseMain;
	import BaseAssets.events.BaseEvent;
	import BaseAssets.tutorial.CaixaTexto;
	import cepa.graph.rectangular.AxisX;
	import cepa.graph.rectangular.SimpleGraph;
	import cepa.graph.SimpleArrow;
	import com.eclecticdesignstudio.motion.Actuate;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	/**
	 * ...
	 * @author Alexandre
	 */
	public class Main extends BaseMain
	{
		private const ESPACAMENTO:int = 50;
		private const _FXYMAX:int = 150;
		private const _FXYMIN:int = -120;
		
		private var _curva:Sprite = new Sprite();
		private var _ponto:Point = new Point();
		private var _pontaSeta:SimpleArrow = new SimpleArrow(10, 10);
		private var _controlPt:Point;
		private var _angle:Number;
		private var _reta:AxisX = new AxisX(-8, 8, 250);
		private var _planoCartesiano = new SimpleGraph( -8, 8, 280, -8, 8, 280);
		
		public function Main() 
		{
			
		}
		
		override protected function init():void 
		{
			_reta.noticks = true;
			_reta.draw();
			retaReal.addChild(_reta);
			retaReal.setChildIndex(retaReal.ponto, retaReal.numChildren - 1);
			
			grafico.fxy.mouseEnabled = false;
			
			_planoCartesiano.mouseChildren = false;
			_planoCartesiano.mouseEnabled = false;
			_planoCartesiano.grid = false;
			_planoCartesiano.enableTicks(SimpleGraph.AXIS_X, false);
			_planoCartesiano.enableTicks(SimpleGraph.AXIS_Y, false);
			grafico.addChild(_planoCartesiano);
			
			addChild(grafico);
			addChild(retaReal);
			addChild(f);
			addChild(ponto);
			
			_curva.mouseEnabled = false;
			_curva.addChild(_pontaSeta);
			addChild(_curva);
			
			ponto.mouseEnabled = false;
			ponto.mouseChildren = false;
			
			_pontaSeta.rotation = 35;
			_pontaSeta.scaleY = 0.7;
			
			retaReal.ponto.x = 100;
			iniciaDesenho(40, 13);
			addListeners();
			
			iniciaTutorial();
		}
		
		private function iniciaAi(e:BaseEvent):void 
		{
			balao.removeEventListener(BaseEvent.CLOSE_BALAO, iniciaAi);
			balao.removeEventListener(BaseEvent.NEXT_BALAO, closeBalao);
			unblockAI();
		}
		
		private function addListeners():void
		{
			grafico.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			grafico.buttonMode = true;
		}
		
		private function overGrafico(e:MouseEvent):void 
		{
			Actuate.tween(retaReal.ponto, 0.5, {alpha:1});
			Actuate.tween(_pontaSeta, 0.5, {alpha:1});
			Actuate.tween(_curva, 0.5, {alpha:1});
			Actuate.tween(f, 0.5, { alpha:1 } );
			Actuate.tween(grafico.fxy, 0.5, { alpha:1 } );
			Actuate.tween(ponto, 0.5, {alpha:1});
		}
		
		private function outGrafico(e:MouseEvent):void 
		{
			Actuate.tween(retaReal.ponto, 0.5, {alpha:0});
			Actuate.tween(_pontaSeta, 0.5, {alpha:0});
			Actuate.tween(_curva, 0.5, {alpha:0});
			Actuate.tween(f, 0.5, { alpha:0 } );
		}
		
		private function onMouseUp(e:MouseEvent):void 
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			grafico.dominio.removeEventListener(MouseEvent.MOUSE_OVER, overGrafico);
			grafico.dominio.removeEventListener(MouseEvent.MOUSE_OUT, outGrafico);
		}
		
		private function onMouseDown(e:MouseEvent):void 
		{
			//trace(e.target.name, e.currentTarget.name);
			
			grafico.dominio.addEventListener(MouseEvent.MOUSE_OVER, overGrafico);
			grafico.dominio.addEventListener(MouseEvent.MOUSE_OUT, outGrafico);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			
			if (grafico.dominio.hitTestPoint(mouseX, mouseY, true)) {
				overGrafico(null);
			}
			else outGrafico(null);

			atualizaReta(e.localX, -e.localY);
		}
		
		private function onMouseMove(e:MouseEvent):void 
		{
			if (grafico.hitTestPoint(mouseX, mouseY, true)) {				
				atualizaReta(e.localX, -e.localY);
			}
			//else onMouseUp(null);
		}

		/**
		 * CRIA O MOVIMENTO DO PONTO NA RETA REAL, A PARTIR DO PAR ORDENADO (X,Y)
		 * A FUNÇÃO UTIZADA É F(X,Y) = X + Y PARA FACILITAR A OBSERVAÇÃO DO MOVIMENTO DE F(X,Y) NA RETA REAL
		 */
		private function atualizaReta(mX, mY):void 
		{
			retaReal.ponto.x = ESPACAMENTO + ((mX + mY + _FXYMAX) / (2 * _FXYMAX)) * (_reta.size - 2 * ESPACAMENTO);
			
			//DESENHA A CURVA E SEGUE O PONTO
			_curva.graphics.clear();
			_curva.graphics.lineStyle(2, 0x000000, 1);
			_ponto = retaReal.localToGlobal(new Point(retaReal.ponto.x, retaReal.ponto.y));
			_curva.graphics.moveTo(mouseX + 10, mouseY - 10);
			grafico.fxy.x = grafico.globalToLocal(new Point(mouseX,mouseY)).x - 40;
			grafico.fxy.y = grafico.globalToLocal(new Point(mouseX, mouseY)).y - 30;
			ponto.x = mouseX;
			ponto.y = mouseY;
			
			//BÉZIER
			_angle = Math.atan2(_ponto.y - mouseY, _ponto.x - mouseX);
			
			_controlPt = new Point(
				mouseX + (_ponto.x - ponto.x) / 2 + 100 * Math.sin(_angle),
				mouseY + (_ponto.y - ponto.y) / 2 - 100 * Math.cos(_angle)
			);
			
			//MOVE O 'F' QUE FICA EM CIMA DA CURVA
			f.x = _controlPt.x;
			f.y = _controlPt.y + 15;
			
			_curva.graphics.curveTo(_controlPt.x, _controlPt.y, _ponto.x - 10, _ponto.y - 10);
			
			//MOVE A PONTA DA FLECHA
			_pontaSeta.x = _ponto.x - 7;
			_pontaSeta.y = _ponto.y - 8;
		}
		
		private function iniciaDesenho(mX, mY):void 
		{
			retaReal.ponto.x = ESPACAMENTO + ((mX + mY + _FXYMAX) / (2 * _FXYMAX)) * (_reta.size - 2 * ESPACAMENTO);
			
			//DESENHA A CURVA E SEGUE O PONTO
			_curva.graphics.clear();
			_curva.graphics.lineStyle(2, 0x000000, 1);
			_ponto = retaReal.localToGlobal(new Point(retaReal.ponto.x, retaReal.ponto.y));
			_curva.graphics.moveTo(ponto.x + 10, ponto.y - 10);
			grafico.fxy.x = grafico.globalToLocal(new Point(ponto.x,ponto.y)).x - 40;
			grafico.fxy.y = grafico.globalToLocal(new Point(ponto.x, ponto.y)).y - 30;
			
			//BÉZIER
			_angle = Math.atan2(_ponto.y - ponto.y, _ponto.x - ponto.x);
			
			_controlPt = new Point(
				ponto.x + (_ponto.x - ponto.x) / 2 + 100 * Math.sin(_angle),
				ponto.y + (_ponto.y - ponto.y) / 2 - 100 * Math.cos(_angle)
			);
			
			//MOVE O 'F' QUE FICA EM CIMA DA CURVA
			f.x = _controlPt.x;
			f.y = _controlPt.y + 15;
			
			_curva.graphics.curveTo(_controlPt.x, _controlPt.y, _ponto.x - 10, _ponto.y - 10);
			
			//MOVE A PONTA DA FLECHA
			_pontaSeta.x = _ponto.x - 7;
			_pontaSeta.y = _ponto.y - 8;
		}
		
		private function changeInfo(e:MouseEvent):void 
		{
			infoBar.info = "";

		}
		
		
		override public function reset(e:MouseEvent = null):void
		{
			ponto.x = 200;
			ponto.y = 160;
			retaReal.ponto.x = 100;
			overGrafico(null);
			iniciaDesenho(40, 13);
		}
		
		//---------------- Tutorial -----------------------
		
		private var balao:CaixaTexto;
		private var pointsTuto:Array;
		private var tutoBaloonPos:Array;
		private var tutoPos:int;
		private var tutoSequence:Array = ["Veja as orientações aqui.", 
										  "Arraste esse ponto.", 
										  "Observe a variação neste ponto.",
										  "A regra (função) f relaciona esses dois pontos."];
		
		
		override public function iniciaTutorial(e:MouseEvent = null):void  
		{
			reset();
			blockAI();
			
			tutoPos = 0;
			if(balao == null){
				balao = new CaixaTexto();
				layerTuto.addChild(balao);
				balao.visible = false;
				
				pointsTuto = 	[new Point(botoes.x - botoes.width - 10, botoes.y - 85),
								new Point(ponto.x, ponto.y),
								new Point(retaReal.ponto.x + retaReal.x - 25, retaReal.ponto.y + retaReal.y),
								new Point(f.x, f.y + 10)];
								
				tutoBaloonPos = [[CaixaTexto.RIGHT, CaixaTexto.CENTER],
								[CaixaTexto.LEFT, CaixaTexto.CENTER],
								[CaixaTexto.RIGHT, CaixaTexto.CENTER],
								[CaixaTexto.TOP, CaixaTexto.CENTER]];
			}
			balao.removeEventListener(BaseEvent.NEXT_BALAO, closeBalao);
			
			balao.setText(tutoSequence[tutoPos], tutoBaloonPos[tutoPos][0], tutoBaloonPos[tutoPos][1]);
			balao.setPosition(pointsTuto[tutoPos].x, pointsTuto[tutoPos].y);
			balao.addEventListener(BaseEvent.NEXT_BALAO, closeBalao);
			balao.addEventListener(BaseEvent.CLOSE_BALAO, iniciaAi);
		}
		
		private function closeBalao(e:Event):void 
		{
			tutoPos++;
			if (tutoPos >= tutoSequence.length) {
				balao.removeEventListener(BaseEvent.NEXT_BALAO, closeBalao);
				balao.visible = false;
				iniciaAi(null);
			}else {
				balao.setText(tutoSequence[tutoPos], tutoBaloonPos[tutoPos][0], tutoBaloonPos[tutoPos][1]);
				balao.setPosition(pointsTuto[tutoPos].x, pointsTuto[tutoPos].y);
			}
		}
	}

}