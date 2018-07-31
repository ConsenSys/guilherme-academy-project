pragma solidity ^0.4.24;

contract ProofStorage {

    address owner;

    enum State { Empty, Generated, Aknowledged, Verified, Discarded }
    
    event LogNewProof(string _proof);
    event LogProofAknowledged(string _proof);
    event LogProofVerified(string _proof);
    event LogProofDiscarded(string _proof);
    event LogProofPayout(string _proof);

    struct Proof {
        uint timestamp;
        State state;
        address sender;
    }
    
    mapping(string => Proof) proofs;

    constructor() public {
        owner = msg.sender;
    }
    
    modifier isOwner() {
        require(owner == msg.sender);
        _;
    }
    
    modifier isCreaterOrOwner(string _proof) {
        require((proofs[_proof].sender == msg.sender) || (owner == msg.sender));
        _;
    }
    
    modifier isProof(string _proof) {
        require(proofs[_proof].state != State.Empty);
        _;
    }
    
    modifier isEmpty(string _proof) {
        require(proofs[_proof].state == State.Empty);
        _;
    }
    
    modifier isGenerated(string _proof) {
        require(proofs[_proof].state == State.Generated);
        _;
    }
    
    modifier isAknowledge(string _proof) {
        require(proofs[_proof].state == State.Aknowledged);
        _;
    }
    
    function provideProof(string _proof) 
    public isEmpty(_proof) {
        proofs[_proof] = Proof(block.timestamp, State.Generated, msg.sender);
        emit LogNewProof(_proof);
    }
    
    function aknowledgeProof(string _proof) 
    public isOwner isGenerated(_proof) {
        proofs[_proof].state = State.Aknowledged;
        emit LogProofAknowledged(_proof);
    }
    
    function verifyProof(string _proof) 
    public isOwner isAknowledge(_proof) {
        proofs[_proof].state = State.Verified;
        emit LogProofVerified(_proof);
        emit LogProofPayout(_proof);
        // At this point, a token transfer should be triggered
    }

    function discardProof(string _proof) 
    public isOwner isAknowledge(_proof) {
        proofs[_proof].state = State.Discarded;
        emit LogProofDiscarded(_proof);
    }
    
    function getProof(string _proof) 
    public view isProof(_proof) isCreaterOrOwner(_proof)
    returns(
        uint,
        State,
        address
    ) {
        return (
            proofs[_proof].timestamp, 
            proofs[_proof].state,
            proofs[_proof].sender
        );
    }
}