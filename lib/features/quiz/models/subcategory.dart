class Subcategory {
  final String? id,languageId,mainCatId,subcategoryName,status,rowOrder,noOfQue,maxLevel;

  Subcategory({this.id,this.status,this.languageId,this.mainCatId,this.maxLevel,this.noOfQue,this.rowOrder,this.subcategoryName});
  factory Subcategory.fromJson(Map<String, dynamic> jsonData) {
    return Subcategory(
        id:jsonData["id"],
        status: jsonData["status"],
        languageId: jsonData["language_id"],
        mainCatId: jsonData["maincat_id"],
        maxLevel: jsonData["maxlevel"],
        noOfQue: jsonData["no_of_que"],
        rowOrder: jsonData["row_order"],
        subcategoryName: jsonData["subcategory_name"]

    );}
}
