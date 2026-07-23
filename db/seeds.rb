puts "Cleaning database..."
Message.destroy_all
Chat.destroy_all
SharedBill.destroy_all
Bill.destroy_all
User.destroy_all

puts "Creating users..."
james = User.create!(email: "james@example.com", password: "password", name: "James")
nina = User.create!(email: "nina@example.com", password: "password", name: "Nina")
cassandra = User.create!(email: "cassandra@example.com", password: "password", name: "Cassandra")

puts "Creating bills for James..."
rent = Bill.create!(
  name: "Rent",
  description: "Monthly apartment rent",
  amount: 90000,
  due_date: Date.today + 10,
  received_date: Date.today - 5,
  category: "Housing",
  user: james
)

electricity = Bill.create!(
  name: "Electricity",
  description: "TEPCO monthly bill",
  amount: 8200,
  due_date: Date.today + 5,
  received_date: Date.today - 2,
  category: "Utilities",
  user: james
)

internet = Bill.create!(
  name: "Internet",
  description: "Fiber broadband",
  amount: 5400,
  due_date: Date.today + 15,
  received_date: Date.today - 1,
  category: "Utilities",
  user: james
)

puts "Creating bills for Nina..."
groceries = Bill.create!(
  name: "Groceries",
  description: "Weekly shopping",
  amount: 12000,
  due_date: Date.today + 3,
  received_date: Date.today,
  category: "Food",
  user: nina
)

puts "Sharing bills..."
SharedBill.create!(bill: rent, user: nina)
SharedBill.create!(bill: rent, user: cassandra)
SharedBill.create!(bill: electricity, user: nina)

puts "Creating a sample chat..."
chat = Chat.create!(user: james, bill: rent)

Message.create!(
  chat: chat,
  role: "user",
  content: "Can you split this rent bill evenly between me and my two roommates?"
)

Message.create!(
  chat: chat,
  role: "assistant",
  content: "Sure! Splitting Y90,000 evenly between 3 people comes to Y30,000 each."
)

puts "Finished seeding!"
puts "Users: #{User.count}"
puts "Bills: #{Bill.count}"
puts "Shared bills: #{SharedBill.count}"
puts "Chats: #{Chat.count}"
puts "Messages: #{Message.count}"
