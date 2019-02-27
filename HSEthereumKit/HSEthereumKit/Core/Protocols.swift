import Foundation
import RxSwift
import HSCryptoKit

protocol IRandomHelper: class {
    func randomKey() -> ECKey
    func randomBytes(length: Int) -> Data
    func randomBytes(length: Range<Int>) -> Data
}

protocol IFactory: class {
    func authMessage(signature: Data, publicKeyPoint: ECPoint, nonce: Data) -> AuthMessage
    func authAckMessage(data: Data) -> AuthAckMessage?
    func keccakDigest() -> KeccakDigest
}

protocol IFrameCodecHelper {
    func updateMac(mac: KeccakDigest, macKey: Data, data: Data) -> Data
    func toThreeBytes(int: Int) -> Data
    func fromThreeBytes(data: Data) -> Int
}

protocol IAESEncryptor {
    func encrypt(_ data: Data) -> Data
}

protocol IECIESCrypto {
    func ecdhAgree(myKey: ECKey, remotePublicKeyPoint: ECPoint) -> Data
    func ecdhAgree(myPrivateKey: Data, remotePublicKeyPoint: Data) -> Data
    func concatKDF(_ data: Data) -> Data
    func sha256(_ data: Data) -> Data
    func aesEncrypt(_ data: Data, withKey: Data, keySize: Int, iv: Data) -> Data
    func hmacSha256(_ data: Data, key: Data, iv: Data, macData: Data) -> Data
}

protocol ICrypto: class {
    func ecdhAgree(myKey: ECKey, remotePublicKeyPoint: ECPoint) -> Data
    func ellipticSign(_ messageToSign: Data, key: ECKey) throws -> Data
    func eciesDecrypt(privateKey: Data, message: ECIESEncryptedMessage) throws -> Data
    func eciesEncrypt(remotePublicKey: ECPoint, message: Data) -> ECIESEncryptedMessage
    func sha3(_ data: Data) -> Data
    func aesEncrypt(_ data: Data, withKey: Data, keySize: Int) -> Data
}

public protocol IEthereumKitDelegate: class {
    func onUpdate(transactions: [EthereumTransaction])
    func onUpdateBalance()
    func onUpdateLastBlockHeight()
    func onUpdateSyncState()
}


protocol IPeerDelegate: class {
    func connected()
    func blocksReceived(blockHeaders: [BlockHeader])
    func proofReceived(message: ProofsMessage)
}

protocol IDevP2PPeerDelegate: class {
    func connectionEstablished()
    func connectionDidDisconnect(withError error: Error?)
    func connection(didReceiveMessage message: IMessage)
}

protocol IConnectionDelegate: class {
    func connectionEstablished()
    func connectionKey() -> ECKey
    func connectionDidDisconnect(withError error: Error?)
    func connection(didReceiveMessage message: IMessage)
}

protocol IPeer: class {
    var delegate: IPeerDelegate? { get set }
    func connect()
    func disconnect(error: Error?)
    func downloadBlocksFrom(block: BlockHeader)
    func getBalance(forAddress address: Data, inBlockWithHash blockHash: Data)
}

protocol IConnection: class {
    var delegate: IConnectionDelegate? { get set }
    var logName: String { get }
    func connect()
    func disconnect(error: Error?)
    func register(capability: Capability)
    func send(message: IMessage)
}

protocol INetwork {
    var id: Int { get }
    var genesisBlockHash: Data { get }
    var checkpointBlock: BlockHeader{ get }
}

protocol IFrameHandler {
    func register(capability: Capability)
    func add(frame: Frame)
    func getMessage() throws -> IMessage?
    func getFrames(from message: IMessage) -> [Frame]
}

protocol IMessage {
    init?(data: Data)
    func encoded() -> Data
    func toString() -> String
}

protocol IPeerGroupDelegate: class {
    func onUpdate(state: AccountState)
}

protocol IPeerGroup {
    var delegate: IPeerGroupDelegate? { get set }
    func start()
}

protocol IReachabilityManager {
    var isReachable: Bool { get }
    var reachabilitySignal: Signal { get }
}

protocol IApiConfigProvider {
    var reachabilityHost: String { get }
    var apiUrl: String { get }
}

protocol IApiProvider {
    func gasPriceInWeiSingle() -> Single<Int>
    func lastBlockHeightSingle() -> Single<Int>
    func transactionCountSingle(address: String) -> Single<Int>

    func balanceSingle(address: String) -> Single<String>
    func balanceErc20Single(address: String, contractAddress: String) -> Single<String>

    func transactionsSingle(address: String, startBlock: Int64) -> Single<[EthereumTransaction]>
    func transactionsErc20Single(address: String, startBlock: Int64) -> Single<[EthereumTransaction]>

    func sendSingle(from: String, to: String, nonce: Int, amount: String, gasPriceInWei: Int, gasLimit: Int) -> Single<EthereumTransaction>
    func sendErc20Single(contractAddress: String, from: String, to: String, nonce: Int, amount: String, gasPriceInWei: Int, gasLimit: Int) -> Single<EthereumTransaction>
}

protocol IPeriodicTimer {
    var delegate: IPeriodicTimerDelegate? { get set }
    func schedule()
    func invalidate()
}

protocol IPeriodicTimerDelegate: class {
    func onFire()
}

protocol IRefreshKitDelegate: class {
    func onRefresh()
    func onDisconnect()
}

protocol IRefreshManager {
    func didRefresh()
}

protocol IAddressValidator {
    func validate(address: String) throws
}

protocol IStorage {
    var lastBlockHeight: Int? { get }
    var gasPriceInWei: Int? { get }

    func balance(forAddress address: String) -> String?
    func lastTransactionBlockHeight(erc20: Bool) -> Int?
    func transactionsSingle(fromHash: String?, limit: Int?, contractAddress: String?) -> Single<[EthereumTransaction]>

    func save(lastBlockHeight: Int)
    func save(gasPriceInWei: Int)
    func save(balance: String, address: String)
    func save(transactions: [EthereumTransaction])

    func clear()
}

protocol IBlockchain {
    var ethereumAddress: String { get }
    var gasPriceInWei: Int { get }
    var gasLimitEthereum: Int { get }
    var gasLimitErc20: Int { get }

    var delegate: IBlockchainDelegate? { get set }

    func start()
    func clear()

    var syncState: EthereumKit.SyncState { get }
    func syncState(contractAddress: String) -> EthereumKit.SyncState

    func register(contractAddress: String)
    func unregister(contractAddress: String)

    func sendSingle(to address: String, amount: String, gasPriceInWei: Int?) -> Single<EthereumTransaction>
    func sendErc20Single(to address: String, contractAddress: String, amount: String, gasPriceInWei: Int?) -> Single<EthereumTransaction>
}

protocol IBlockchainDelegate: class {
    func onUpdate(lastBlockHeight: Int)

    func onUpdate(balance: String)
    func onUpdateErc20(balance: String, contractAddress: String)

    func onUpdate(syncState: EthereumKit.SyncState)
    func onUpdateErc20(syncState: EthereumKit.SyncState, contractAddress: String)

    func onUpdate(transactions: [EthereumTransaction])
    func onUpdateErc20(transactions: [EthereumTransaction], contractAddress: String)
}
