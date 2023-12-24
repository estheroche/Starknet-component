use starknet::{ContractAddress, contract_address_try_from_felt252,contract_address_const};
use option::OptionTrait;
use starknet::testing;


fn ADMIN() -> ContractAddress {
    contract_address_try_from_felt252('admin').unwrap()
}


fn AUTHORIZED() -> ContractAddress {
    contract_address_const::<'AUTHORIZED'>()
}

fn drop_event(address: ContractAddress) {
     testing::pop_log_raw(address).unwrap();
}

fn ZERO() -> ContractAddress {
    contract_address_const::<0>()
}

fn pop_log<T, impl TDrop: Drop<T>, impl TEvent: starknet::Event<T>>(
    address: ContractAddress
) -> Option<T> {
    let (mut keys, mut data) = testing::pop_log_raw(address)?;

    // Remove the event ID from the keys
    keys.pop_front();

    let ret = starknet::Event::deserialize(ref keys, ref data);
    assert(data.is_empty(), 'Event has extra data');
    ret
}

fn assert_no_events_left(address: ContractAddress) {
    assert(testing::pop_log_raw(address).is_none(), 'Events remaining on queue');
}

const ROLE: felt252 = 'ROLE';
const OTHER_ROLE: felt252 = 'OTHER_ROLE';
const DEFAULT_ADMIN:felt252 = '0';

fn OTHER() -> ContractAddress {
    contract_address_try_from_felt252('other').unwrap()
}