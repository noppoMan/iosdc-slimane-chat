import Suv

func setTimeout(_ timeout: Int, _ callback: (Void) -> Void){
  let t = TimerWrap(tick: 5000)
  t.start {
      t.end()
      callback()
  }
}
