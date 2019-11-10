extension Publisher where Self.Output : Encodable {

    /// Encodes the output from upstream using a specified `TopLevelEncoder`.
    /// For example, use `JSONEncoder`.
    public func encode<Coder>(encoder: Coder) -> Publishers.Encode<Self, Coder> where Coder : TopLevelEncoder {
        return .init(upstream: self, encoder: encoder)
    }
}

extension Publishers {

    public struct Encode<Upstream, Coder> : Publisher where Upstream : Publisher, Coder : TopLevelEncoder, Upstream.Output : Encodable {

        public typealias Failure = Error

        public typealias Output = Coder.Output

        public let upstream: Upstream
        
        private let encoder: Coder

        public init(upstream: Upstream, encoder: Coder) {
            self.upstream = upstream
            self.encoder = encoder
        }

        public func receive<S>(subscriber: S) where S : Subscriber, Coder.Output == S.Input, S.Failure == Publishers.Encode<Upstream, Coder>.Failure {
            self.upstream
                .tryMap {
                    try self.encoder.encode($0)
                }
                .receive(subscriber: subscriber)
        }
    }
}
