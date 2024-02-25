import SwiftUI
import SceneKit
import CoreMotion
import SpriteKit

final class SpriteScene: SKScene {
    static var shared = SpriteScene()
    var motionManger: MotionManager?
    var nodes: [SKNode] = []
    var feelingDatas: [Feelinginfo] = []
    
    func replaceNode(name: String) {
        let node = nodes.filter{$0.name == name}[0]
        node.removeFromParent()
        let tree = createNewTree()
        tree.position = node.position
        nodes.append(tree)
        addChild(tree)
    }
    func createNewTree() -> SKSpriteNode {
        let newtree = SKSpriteNode(imageNamed: "tree")
        newtree.name = "newtree"
        newtree.physicsBody = SKPhysicsBody(circleOfRadius: newtree.size.width / 2)
        newtree.physicsBody?.restitution = 0.5
        return newtree
    }
    override func didMove(to view: SKView) {
        backgroundColor = .background
        motionManger?.setCoreMotionManager()
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        for feeling in feelingDatas {
            let node = createNode(for: feeling)
            nodes.append(node)
            addChild(node)
        }
        for _ in 0..<30 - feelingDatas.count{
            let newtree = SKSpriteNode(imageNamed: "tree")
            newtree.name = "newtree"
            newtree.physicsBody = SKPhysicsBody(circleOfRadius: newtree.size.width / 2)
            newtree.physicsBody?.restitution = 0.5 //얼마나 튕길래
            newtree.position = CGPoint(x: CGFloat.random(in: 0...size.width * 0.9), y: CGFloat.random(in: size.height * 0.1...size.height * 0.9))
            nodes.append(newtree)
            addChild(newtree)
        }
    }
    func createNode(for feeling: Feelinginfo) -> SKSpriteNode {
        let imageName: String
        switch feeling.feeling {
        case "good":
            imageName = "sun"
        case "angry":
            imageName = "angrycloud"
        case "normal":
            imageName = "normal"
        case "sad":
            imageName = "sadcloud"
        case "self\nloathing":
            imageName = "selfhate"
        case "suicidal\nthoughts":
            imageName = "thunder"
        default:
            imageName = "default"
        }
        
        let node = SKSpriteNode(imageNamed: imageName)
        node.name = feeling.date
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        node.physicsBody?.restitution = 0.5
        node.position = CGPoint(x: CGFloat.random(in: 0...size.width * 0.9), y: CGFloat.random(in: size.height * 0.1...size.height * 0.9))
        return node
    }
    override func update(_ currentTime: TimeInterval) {
        if let accelerometerDate = motionManger?.coreMotionmanger.accelerometerData {
            physicsWorld.gravity = CGVector(dx: accelerometerDate.acceleration.x * 1, dy: accelerometerDate.acceleration.y * 1)
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)
        for node in touchedNodes {
            if node.name == "newtree" {
                NotificationCenter.default.post(name: NSNotification.Name("TreeTapped"), object: nil)
            }
            else {
                NotificationCenter.default.post(name: NSNotification.Name("FeelingTapped"), object: node)
            }
        }
    }
}
