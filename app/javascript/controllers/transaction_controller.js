import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "source", 'balance', 'fee', 'out', 'change', 'inValue']//, 'inBalance'];//, 'inAddr', 'in_addr']; //, 'changeAddr', 'change_addr' ]
  static values = { inBalance: { type: Number, default: 2 } }
 
  connect() {
    
  }

  change_input(event) {
    var eid = this.sourceTarget.selectedOptions[0].dataset.eid
    var balance = this.sourceTarget.selectedOptions[0].dataset.balance
    this.balanceTarget.value = balance
  }

  change_in(event) {
    var inValue = Number(this.inValueTarget.value);
    var fee = Math.round(0.03 * inValue);
    this.feeTarget.value = fee;
    var out = inValue + fee;
    this.outTarget.value = out;

    var balance = this.sourceTarget.selectedOptions[0].dataset.balance
    var change = balance - out
    this.changeTarget.value =  change;
  }
}