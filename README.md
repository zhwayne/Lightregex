# Lightregx
A lightweight regular expression operation.



# Usage

1. Checks if the regular expression matches a string.

   ```swift
   let regx: Lightregx = "^1[3|4|5|6|7|8][0-9]\\d{4,8}$"
   print(regx.match(in: "17012345678"))	// true
   
   // OR
   "17012345678".match(regx: "^1[3|4|5|6|7|8][0-9]\\d{4,8}$")
   ```


2. Get matching string(s).

   ```swift
   let regx: Lightregx = "(\\d{3})-(\\d{3,8})"
   let res = regx.fetchAll(in: "Tel: 010-12345 & 027-12345678")
   print(res.map { $0.string })	// ["010-12345", "027-12345678"]
   print(res.map { $0.groups })	// [["010", "12345"], ["027", "12345678"]]
   
   // OR
   "Tel: 010-12345 & 027-12345678".fetchAll(regx: "(\\d{3})-(\\d{3,8})")
   ```

3. Replace string using a template string.

   ```swift
   let text = "I bought this pair of shoes for $50 this afternoon at 3pm."
   let regx = Lightregx(regx: "\\d")!
   let res = regx.replace(in: text, using: "*")
   print(res)		// "I bought this pair of shoes for $** this afternoon at *pm."
   
   // OR
   text.replace(regx: "\\d", using: "*")
   ```

4. Replace string with transform.

   ```swift
   let regx: Lightregx = "\\d"
   let res = regx.replace(in: "A1B23C45D678E") { "\(Int($0)! * 2)" }
   print(res)	// "A2B46C810D121416E"
   
   let regx: Lightregx = "\\d+"
   let res = regx.replace(in: "A1B23C45D678E") { "\(Int($0)! * 2)" }
   print(res)	// "A2B46C90D1356E"
   
   // OR
   "A1B23C45D678E".replace(regx: "\\d+") { "\(Int($0)! * 2)" }
   ```

   