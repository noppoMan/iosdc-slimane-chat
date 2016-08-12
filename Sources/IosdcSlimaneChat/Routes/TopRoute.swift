import Slimane
import Render
import MustacheViewEngine

struct TopRoute: AsyncResponder {

  func respond(to request: Request, result: @escaping ((Void) throws -> Response) -> Void){
      result {
          let render = Render(engine: MustacheViewEngine(templateData: ["isAuthenticated": request.isAuthenticated]), path: "index")
          return Response(custom: render)
      }
  }

}
