class Payment < ApplicationRecord
  validates :customer_name, presence: true
  validates :local_committee, presence: true
  validates :application_id, presence: true
  validates :program, presence: true
  validates :opportunity_name, presence: true
  validates :value, presence: true

  enum program: { gv: 0, ge: 1, gt: 2 }
  enum local_committee: {
    curitiba: 0,
    brasilia: 1,
    limeira: 2,
    porto_alegre: 3,
    uberlandia: 4
  }
  enum status: {
    processing: 0,
    authorized: 1,
    paid: 2,
    refunded: 3,
    waiting_payment: 4,
    pending_refund: 5,
    refused: 6,
    chargedback: 7
  }

end