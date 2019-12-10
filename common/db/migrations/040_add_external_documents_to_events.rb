Sequel.migration do
  up do
    alter_table(:external_document) do
      add_column(:event_id, :integer, null: true)
      add_foreign_key([:event_id], :event, key: :id, name: 'event_external_document_fk')
    end
  end

  down do
    alter_table(:external_document) do
      drop_constraint('event_external_document_fk')
    end

    run('alter table external_document drop foreign key event_external_document_fk') if $db_type == :mysql
  end
end
