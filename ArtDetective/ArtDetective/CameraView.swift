//
//  CameraView.swift
//  ArtDetective
//
//  Created by Radolina on 16/05/2023.
//

import SwiftUI
import AVFoundation




struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView()
    }
}

struct CameraView: View{
    @StateObject var camera = CameraModel()
    
    var body: some View {
        ZStack{
            CameraPreview(camera: camera)
                .ignoresSafeArea(.all, edges: .all)
            
            VStack{
                
                if camera.isTaken{
                    HStack {
                        
                        Spacer()
                        
                        Button(action: {}, label: {
                            Image(systemName: "arrow.triangle.2.circlepath.camera")
                                .foregroundColor(.black)
                                .padding()
                                .background(Color.white)
                                .clipShape(Circle())
                        })
                        .padding(.trailing, 10)
                    }
                    
                    
                }
                    
                    Spacer()
                    
                    HStack{
                        if camera.isTaken{
                            Button(action: {}, label: {
                                Text("Save")
                                    .foregroundColor(.black)
                                    .fontWeight(.semibold)
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 20)
                                    .background(Color.white)
                                    .clipShape(Capsule())
                            })
                            .padding(.leading)
                            
                            Spacer()
                            
                        }
                        else{
                            Button(action: camera.takePic, label: {
                                ZStack{
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 65, height: 65)
                                    Circle()
                                        .stroke(Color.white, lineWidth: 2)
                                        .frame(width: 75, height: 75)
                                }
                            })
                        }
                    }
                    .frame(height: 75)
                }
            }
        .onAppear(perform: {
            camera.Check()
        })
        }
    }
    
    class CameraModel : NSObject, ObservableObject, AVCapturePhotoCaptureDelegate{
        @Published var isTaken = false
        
        @Published var session = AVCaptureSession()
        
        @Published var alert = false
        
        @Published var output = AVCapturePhotoOutput()
        
        @Published var preview :  AVCaptureVideoPreviewLayer!
        
        func Check(){
            //check camera permission
            
            switch AVCaptureDevice.authorizationStatus(for: .video){
                
            case .authorized:
                setUp()
                return
                //set up sesion
            case .notDetermined:
                //permission
                AVCaptureDevice.requestAccess(for: .video){
                    (status) in
                    
                    if status{
                        
                        self.setUp()
                    }
                }
                
            case .denied:
                self.alert.toggle()
                return
            default:
                return
            }
        }
        
        func setUp(){
            do{
                self.session.beginConfiguration()
                let device = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back)
                
                let input = try AVCaptureDeviceInput(device: device!)
                
                //checking and adding session
                
                if self.session.canAddInput(input){
                    self.session.addInput(input)
                }
                
                if self.session.canAddOutput(self.output){
                    self.session.addOutput(self.output)
                }
                
                self.session.commitConfiguration()
            }
            catch{
                print(error.localizedDescription)
                
            }
        }
        //take and retake func
        
        
        
        func takePic(){
            DispatchQueue.global(qos: .background).async {
                self.output.capturePhoto(with: AVCapturePhotoSettings(),delegate: self)
                self.session.stopRunning()
                
                DispatchQueue.main.async {
                    withAnimation{self.isTaken.toggle()}
                }
            }
        }
        
        func retakePhoto(){
            DispatchQueue
                .global(qos: .background).async {
                    self.session.startRunning()
                    
                    DispatchQueue.main.async {
                        withAnimation{self.isTaken.toggle()}
                    }
                }
        }
        
        func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto: AVCapturePhoto,  error:Error?) {
            
            if error != nil{
                return
            }
            print("picture taken...")
        }
    }


struct CameraPreview: UIViewRepresentable{
    
    @ObservedObject var camera : CameraModel
    func makeUIView(context: Context) ->  UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        camera.preview = AVCaptureVideoPreviewLayer(session: camera.session)
        camera.preview.frame = view.frame
        
        camera.preview.videoGravity = .resizeAspectFill
        view.layer.addSublayer(camera.preview)
        
        camera.session.startRunning()
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
}
