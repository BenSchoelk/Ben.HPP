class Category {
  final String? id, languageId, categoryName, image, rowOrder, noOf, noOfQqe, maxLevel;

  Category({this.languageId, this.categoryName, this.image, this.rowOrder, this.noOf, this.noOfQqe, this.maxLevel, this.id});
  factory Category.fromJson(Map<String, dynamic> jsonData) {
    return Category(
        id: jsonData["id"], languageId: jsonData["language_id"], categoryName: jsonData["category_name"], image: jsonData["image"], rowOrder: jsonData["row_order"], noOf: jsonData["no_of"], noOfQqe: jsonData["no_of_que"], maxLevel: jsonData["maxlevel"]);
  }
}
