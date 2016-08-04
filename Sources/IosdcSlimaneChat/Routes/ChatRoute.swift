import Slimane
import Render
import MustacheViewEngine

struct ChatRoute: AsyncResponder {

  func respond(to request: Request, result: ((Void) throws -> Response) -> Void){
      result {
          let data: TemplateData = [
              "roomName": request.params["roomName"]!,
              "currentUser": request.currentUser!.serialize(),
          ]
          let render = Render(engine: MustacheViewEngine(templateData: data), path: "chat")
          return Response(custom: render)
      }
  }

}
