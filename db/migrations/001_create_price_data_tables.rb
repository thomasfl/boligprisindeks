Sequel.migration do

  up do
    create_table(:bolig_type) do
      primary_key :bolig_type_id
      String :bolig_type_navn, :null=>false
    end

    create_table(:bolig_omrade) do
      primary_key :bolig_omrade_id
      String :bolig_omrade_navn, :null=>false
    end

    alter_table(:bolig_omrade) do
      add_index :bolig_omrade_navn
    end

    create_table(:periode) do
      primary_key :periode_id
      Date :periode_start
    end

    alter_table(:periode) do
      add_index :periode_start
    end

    create_table(:boligpris_historikk) do
      primary_key :boligpris_historikk_id
      Integer :bolig_type_id, :null => false
      Integer :bolig_omrade_id, :null => false
      Integer :periode_id, :null => false
      Float :m2_pris, :null => false
    end

    alter_table(:boligpris_historikk) do
      add_index :bolig_type_id
      add_index :bolig_omrade_id
      add_index :periode_id
    end

  end

  down do
    drop_table(:bolig_type)
    drop_table(:bolig_omrade)
    drop_table(:periode)
    drop_table(:boligpris_historikk)
  end

end
