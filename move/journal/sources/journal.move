module journal::journal {
    use std::string::String;
    use sui::clock::Clock;

    /// An owned Sui object representing a journal
    public struct Journal has key, store {
        id: UID,
        owner: address,
        title: String,
        entries: vector<Entry>,
    }

    /// A struct representing a journal entry
    public struct Entry has store {
        content: String,
        create_at_ms: u64,
    }

    /// Creates and returns a new Journal object with an empty entries vector
    public fun new_journal(title: String, ctx: &mut TxContext): Journal {
        Journal {
            id: object::new(ctx),
            owner: ctx.sender(),
            title,
            entries: vector::empty<Entry>(),
        }
    }

    /// Creates a new Journal and transfers it to the sender
    public entry fun create_journal(title: String, ctx: &mut TxContext) {
        let journal = Journal {
            id: object::new(ctx),
            owner: ctx.sender(),
            title,
            entries: vector::empty<Entry>(),
        };
        transfer::transfer(journal, ctx.sender());
    }

    /// Adds a new entry to the journal
    /// Verifies the caller is the journal owner
    public fun add_entry(
        journal: &mut Journal,
        content: String,
        clock: &Clock,
        ctx: &TxContext
    ) {
        // Verify the caller is the journal owner
        assert!(journal.owner == ctx.sender(), 0);

        // Create a new entry with the content and current timestamp
        let entry = Entry {
            content,
            create_at_ms: clock.timestamp_ms(),
        };

        // Add the entry to the journal's entries vector
        journal.entries.push_back(entry);
    }
}
