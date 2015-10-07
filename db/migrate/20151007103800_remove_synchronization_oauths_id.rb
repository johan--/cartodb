Sequel.migration do
  up do
    Rails::Sequel.connection.run(%{
        ALTER TABLE synchronization_oauths DROP COLUMN id;
      })
  end

  down do
    Rails::Sequel.connection.run(%{
        ALTER TABLE synchronization_oauths ADD PRIMARY KEY (id);
      })
  end
end
