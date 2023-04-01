import Principal "mo:base/Principal";
import HashMap "mo:base/HashMap";
import Debug "mo:base/Debug";
import Iter "mo:base/Iter";

actor Token {

  let owner : Principal = Principal.fromText("amzsn-ujxjh-nalvf-yq6nb-67ebm-bh7xf-2jyiy-uckoz-cfu4z-2lm5l-2qe");
  let totalSupply : Nat = 1000000000;
  let symbol : Text = "KOOK";

  private stable var balanceEntries: [(Principal, Nat)] = [];

  private var balances = HashMap.HashMap<Principal, Nat>(1, Principal.equal, Principal.hash);

    // if it's empty
  if (balances.size() < 1) {
    balances.put(owner, totalSupply);
  };



  public query func balanceOf(who: Principal) : async Nat {

    let balance : Nat = switch (balances.get(who)) {
      // if result of method call is null, then return 0
      case null 0;
      // if it's an optional, get rid of the optional
      case (?result) result;
    };

    return balance;

    // // if user does not exist
    // if (balances.get(who) == null) {
    //   return 0;
    // } else {
    //   return balances.get(who);
    // }
  };

  public query func getSymbol() : async Text {
    return symbol;
  };

  public shared(msg) func payOut() : async Text {
    Debug.print(debug_show(msg.caller));

    // if null then account doesn't exist
    if (balances.get(msg.caller) == null) {
      // create a new user with a set amount of tokens
      //balances.put(msg.caller, 10000);
      
      // transfer money from original balance
      let result = await transfer(msg.caller, 10000);
      return result;

    } else {
      return "Already Claimed";
    }

  };

  public shared(msg) func transfer(to: Principal, amount: Nat) : async Text {
    let fromBalance = await balanceOf(msg.caller);

    // if there's enough money
    if (fromBalance > amount) {

      // sender
      // update to the new Balance after the transaction (subtraction)
      let newFromBalance : Nat = fromBalance - amount;
      balances.put(msg.caller, newFromBalance);

      // recipient 
      // add money to the account being transferred to
      let toBalance = await balanceOf(to);
      let newToBalance = toBalance + amount;
      balances.put(to, newToBalance);

      return "Success";
    } else {
      return "Insufficient funds";
    }

  };

  // Iterate through HashMap to create an Array
  system func preupgrade() {
    balanceEntries := Iter.toArray(balances.entries());
  };

  // Get values of array and put it back into HashMap
  system func postupgrade() {
    balances := HashMap.fromIter<Principal, Nat>(balanceEntries.vals(), 1, Principal.equal, Principal.hash);

    // if it's empty
    if (balances.size() < 1) {
        balances.put(owner, totalSupply);
    }
  };
}