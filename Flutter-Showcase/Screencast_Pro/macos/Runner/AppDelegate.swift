import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate, NetServiceDelegate {
  private var netService: NetService?

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }

  override func applicationDidFinishLaunching(_ notification: Notification) {
    super.applicationDidFinishLaunching(notification)
    registerCastingService()
  }

  override func applicationWillTerminate(_ notification: Notification) {
    netService?.stop()
  }

  // Registers this Mac as a discoverable casting receiver on the local network
  // Mobile app finds it via mDNS query for "_casting._tcp"
  private func registerCastingService() {
    let name = Host.current().localizedName ?? "Mac Receiver"
    netService = NetService(domain: "local.", type: "_casting._tcp.", name: name, port: 8765)
    netService?.delegate = self
    netService?.publish()
  }

  func netServiceDidPublish(_ sender: NetService) {
    NSLog("[Casting] Registered on local network: %@._casting._tcp (port %ld)", sender.name, sender.port)
  }

  func netService(_ sender: NetService, didNotPublish errorDict: [String: NSNumber]) {
    NSLog("[Casting] Registration failed: %@", errorDict)
  }
}
