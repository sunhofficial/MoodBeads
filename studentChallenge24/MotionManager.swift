import SwiftUI
import CoreMotion

protocol CoreMotionServiceType {
    var coreMotionmanger: CMMotionManager {get set}
    func setCoreMotionManager()

}

class MotionManager: CoreMotionServiceType {
    var coreMotionmanger: CMMotionManager = CMMotionManager()
    func setCoreMotionManager() {
        coreMotionmanger.accelerometerUpdateInterval = 0.1
        coreMotionmanger.deviceMotionUpdateInterval = 0.1
        coreMotionmanger.gyroUpdateInterval = 0.1
        coreMotionmanger.startGyroUpdates()
        coreMotionmanger.startAccelerometerUpdates()
    }
    func deleteDetect(completion: @escaping () -> Void)  {
        coreMotionmanger.startAccelerometerUpdates(to: .main, withHandler: { data, err in
            guard let acceleration = data?.acceleration else {return}
            let totalAcceleation = sqrt(pow(acceleration.x, 2) + pow(acceleration.y, 2) + pow(acceleration.z, 2))
            if totalAcceleation > 2.5 {
                completion()
                self.coreMotionmanger.stopAccelerometerUpdates()
            }
        })
    }

}
