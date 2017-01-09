# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170108085856) do

  create_table "categories", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "eng_name",   limit: 255
    t.string   "status",     limit: 255
    t.string   "remark",     limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "categories", ["name"], name: "index_categories_on_name", unique: true, using: :btree

  create_table "channel_schedule_versions", force: :cascade do |t|
    t.integer  "channel_id", limit: 4
    t.date     "active_day"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "channels", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "timezone",   limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "final_schedule_programs", force: :cascade do |t|
    t.integer  "channel_id", limit: 4
    t.date     "date"
    t.integer  "program_id", limit: 4
    t.string   "episode_id", limit: 255
    t.integer  "hour",       limit: 4
    t.integer  "minute",     limit: 4
    t.integer  "second",     limit: 4
    t.string   "status",     limit: 255
    t.string   "remark",     limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "final_schedule_programs", ["channel_id", "date"], name: "index_final_schedule_programs_on_channel_id_and_date", using: :btree

  create_table "program_episodes", force: :cascade do |t|
    t.integer  "program_id",    limit: 4
    t.string   "episode_id",    limit: 255
    t.integer  "episode",       limit: 4
    t.date     "date"
    t.integer  "video_id",      limit: 4
    t.boolean  "is_short_clip"
    t.boolean  "is_special"
    t.string   "status",        limit: 255
    t.string   "remark",        limit: 255
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "program_episodes", ["is_short_clip"], name: "index_program_episodes_on_is_short_clip", using: :btree
  add_index "program_episodes", ["program_id", "episode_id"], name: "index_program_episodes_on_program_id_and_episode_id", unique: true, using: :btree
  add_index "program_episodes", ["video_id"], name: "index_program_episodes_on_video_id", unique: true, using: :btree

  create_table "programs", force: :cascade do |t|
    t.string   "name",              limit: 255
    t.string   "code",              limit: 255
    t.string   "eng_name",          limit: 255
    t.integer  "category_id",       limit: 4
    t.integer  "provider_id",       limit: 4
    t.integer  "total_episodes",    limit: 4
    t.string   "language",          limit: 255
    t.boolean  "is_in_house",                   default: false
    t.boolean  "is_live",                       default: false
    t.boolean  "is_children",                   default: false
    t.integer  "expected_duration", limit: 4
    t.string   "status",            limit: 255
    t.string   "remark",            limit: 255
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
  end

  add_index "programs", ["code"], name: "index_programs_on_code", unique: true, using: :btree
  add_index "programs", ["name"], name: "index_programs_on_name", unique: true, using: :btree

  create_table "providers", force: :cascade do |t|
    t.string   "code",       limit: 255
    t.string   "name",       limit: 255
    t.string   "full_name",  limit: 255
    t.string   "eng_name",   limit: 255
    t.string   "source",     limit: 255
    t.string   "status",     limit: 255
    t.string   "remark",     limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "providers", ["code"], name: "index_providers_on_code", unique: true, using: :btree
  add_index "providers", ["name"], name: "index_providers_on_name", unique: true, using: :btree

  create_table "schedule_program_episodes", force: :cascade do |t|
    t.integer  "channel_id", limit: 4
    t.date     "date"
    t.integer  "program_id", limit: 4
    t.string   "episode_id", limit: 255
    t.integer  "hour",       limit: 4
    t.integer  "minute",     limit: 4
    t.integer  "second",     limit: 4
    t.string   "status",     limit: 255
    t.string   "remark",     limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "schedule_program_episodes", ["channel_id", "date"], name: "index_schedule_program_episodes_on_channel_id_and_date", using: :btree

  create_table "schedule_programs", force: :cascade do |t|
    t.integer  "channel_id",  limit: 4
    t.integer  "version",     limit: 4
    t.string   "program_id",  limit: 255
    t.integer  "week_option", limit: 4
    t.integer  "day",         limit: 4
    t.integer  "hour",        limit: 4
    t.integer  "minute",      limit: 4
    t.integer  "second",      limit: 4
    t.string   "status",      limit: 255
    t.string   "remark",      limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "schedule_programs", ["channel_id", "version"], name: "index_schedule_programs_on_channel_id_and_version", using: :btree

  create_table "videos", force: :cascade do |t|
    t.string   "path",              limit: 255
    t.string   "format",            limit: 255
    t.integer  "size",              limit: 4
    t.integer  "duration",          limit: 4
    t.float    "mux_bitrate",       limit: 24
    t.boolean  "variable_mux_rate"
    t.string   "video_codec",       limit: 255
    t.float    "video_bitrate",     limit: 24
    t.float    "frame_rate",        limit: 24
    t.integer  "video_height",      limit: 4
    t.integer  "video_width",       limit: 4
    t.string   "audio_codec",       limit: 255
    t.float    "audio_bitrate",     limit: 24
    t.integer  "audio_sample_rate", limit: 4
    t.string   "status",            limit: 255
    t.string   "remark",            limit: 255
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "videos", ["path"], name: "index_videos_on_path", unique: true, using: :btree

end
