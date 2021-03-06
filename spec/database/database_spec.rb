require 'spec_helper'
require 'database/database'
require 'collection/collection'
require 'query/query'
require 'user/user'

describe Azure::DocumentDB::Database do
  let(:url) { 'our_url' }
  let(:resource_type) { 'dbs' }
  let(:dbs_url) { "#{url}/#{resource_type}" }
  let(:context) { gimme(Azure::DocumentDB::Context) }
  let(:rest_client) { gimme } # We will inject module RestClient for testability
  let(:master_token) { gimme(Azure::DocumentDB::MasterToken) }
  let(:secure_header) { gimme(Azure::DocumentDB::SecureHeader) }
  let(:collection) { gimme(Azure::DocumentDB::Collection) }
  let(:query) { gimme(Azure::DocumentDB::Query) }
  let(:user) { gimme(Azure::DocumentDB::User) }
  let(:database_name) { 'new_database' }
  let(:database_id) { '0EWFAA==' }
  let(:default_header) { 'default_header' }
  let(:default_header_with_signed_id) { 'default_header_with_id' }
  let(:database1) { { 'id' => database_name, '_rid' => database_id, '_ts' => 1408176196 } }
  let(:database2) { { 'id' => 'unimportant_other', '_rid' => 'junk', '_ts' => 1408176196 } }

  let(:list_result) { { '_rid' => '', 'Databases' => [database1], '_count' => 1 } }

  let(:create_body) { { 'id' => database_name } }
  let(:create_response) { database1 }

  let(:target_url) { "#{dbs_url}/#{database_id}" }

  let(:get_response) { database1 }

  let(:database) { Azure::DocumentDB::Database.new context, rest_client }

  before(:each) {
    give(context).master_token { master_token }
    give(context).endpoint { url }
    give(context).service_version { serv_version }
    give(Azure::DocumentDB::SecureHeader).new(master_token, resource_type) { secure_header }
    give(Azure::DocumentDB::Collection).new(context, rest_client, database_id) { collection }
    give(Azure::DocumentDB::Query).new(context, rest_client, Azure::DocumentDB::ResourceType.DATABASE, '', dbs_url) { query }
    give(Azure::DocumentDB::User).new(context, rest_client, database_id) { user }
    give(secure_header).header('get') { default_header }
    give(secure_header).header('get', database_id) { default_header_with_signed_id }
    give(secure_header).header('post') { default_header }
    give(secure_header).header('delete', database_id) { default_header_with_signed_id }
    give(rest_client).get(dbs_url, default_header) { list_result.to_json }
    give(rest_client).post(dbs_url, create_body.to_json, default_header) { create_response.to_json }
    give(rest_client).get(target_url, default_header_with_signed_id) { get_response.to_json }
  }

  it 'can list the existing databases' do
    expect(database.list).to eq list_result
  end

  it 'can create a new database' do
    expect(database.create database_name).to eq create_response
  end

  it 'can delete a supplied database' do
    database.delete database_id
    verify(rest_client).delete target_url, default_header_with_signed_id
  end

  it 'can get a supplied database' do
    expect(database.get database_id).to eq get_response
  end

  it 'can get the uri of the database resource' do
    expect(database.uri).to eq dbs_url
  end

  it 'can create a collection for a named database' do
    expect(database.collection_for_name database_name).to eq collection
  end

  it 'throws an ArgumentError when supplied a resource name of a database that does not exist when trying to create a collection' do
    expect { database.collection_for_name 'does_not_exist' }.to raise_error ArgumentError, 'Database for supplied name must exist'
  end

  it 'can create a collection for the _rid of a database' do
    expect(database.collection_for_rid database_id).to eq collection
  end

  it 'throws an ArgumentError when supplied a resource id of a database that does not exist when trying to create a collection' do
    expect { database.collection_for_rid 'does_not_exist' }.to raise_error ArgumentError, 'Database for supplied resource id must exist'
  end

  it 'can create a user for a named database' do
    expect(database.user_for_name database_name).to eq user
  end

  it 'throws an ArgumentError when supplied a resource name of a database that does not exist when trying to create a user' do
    expect { database.user_for_name 'does_not_exist' }.to raise_error ArgumentError, 'Database for supplied name must exist'
  end

  it 'can create a user for the _rid of a database' do
    expect(database.user_for_rid database_id).to eq user
  end

  it 'throws an ArgumentError when supplied a resource id of a database that does not exist when trying to create a user' do
    expect { database.user_for_rid 'does_not_exist' }.to raise_error ArgumentError, 'Database for supplied resource id must exist'
  end

  it 'can create a query for the database object' do
    expect(database.query).to eq query
  end
end
